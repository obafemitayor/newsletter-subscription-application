# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubscriptionService do
  let(:customer) { create(:customer) }
  let(:category1) { create(:category) }
  let(:category2) { create(:category) }

  describe '.create_subscription' do
    it 'should create new subscription successfully when customer does not exist' do
      SubscriptionService.create_subscription(
        work_email: 'new_customer@example.com',
        first_name: 'New',
        last_name: 'Customer',
        category_guids: [category1.guid, category2.guid]
      )
      new_customer = Customer.last
      expect(new_customer.work_email).to eq('new_customer@example.com')
      expect(new_customer.first_name).to eq('New')
      expect(new_customer.last_name).to eq('Customer')
      expect(new_customer.guid).to be_present

      subscriptions = Subscription.where(customer_id: new_customer.id)
      expect(subscriptions.pluck(:category_id)).to contain_exactly(category1.id, category2.id)
    end

    it 'should create new subscription successfully when customer exists' do
      SubscriptionService.create_subscription(
        work_email: customer.work_email,
        first_name: customer.first_name,
        last_name: customer.last_name,
        category_guids: [category1.guid, category2.guid]
      )

      expect(Customer.last).to eq(customer)
      subscriptions = Subscription.where(customer_id: customer.id)
      expect(subscriptions.pluck(:category_id)).to contain_exactly(category1.id, category2.id)
    end

    it 'should create new subscription successfully when category_guids contains existing subscriptions' do
      create(:subscription, customer: customer, category: category1)

      SubscriptionService.create_subscription(
        work_email: customer.work_email,
        first_name: customer.first_name,
        last_name: customer.last_name,
        category_guids: [category1.guid, category2.guid]
      )

      subscriptions = Subscription.where(customer_id: customer.id)
      expect(subscriptions.pluck(:category_id)).to contain_exactly(category1.id, category2.id)
    end
  end

  describe '.get_subscriptions' do
    let(:customer1) { create(:customer) }
    let(:customer2) { create(:customer) }
    let(:customer3) { create(:customer) }
    let!(:subscription1) { create(:subscription, customer: customer1, category: category1) }
    let!(:subscription2) { create(:subscription, customer: customer2, category: category2) }
    let!(:subscription3) { create(:subscription, customer: customer3, category: category1) }
    let!(:deleted_subscription) { create(:subscription, deleted_at: Time.current) }

    it 'returns paginated record when category_guids is not provided and data is less than limit' do
      result = SubscriptionService.get_subscriptions(limit: 5)

      expect(result[:subscriptions].length).to eq(3)
      expect(result[:next_cursor]).to eq(subscription3.id)
      expect(result[:previous_cursor]).to eq(subscription1.id)
      
      result[:subscriptions].each do |subscription|
        expect(subscription).to include(
          'work_email' => be_a(String),
          'first_name' => be_a(String),
          'last_name' => be_a(String),
          'category_name' => be_a(String)
        )
      end
    end

    it 'returns paginated record when category_guids is not provided and data is more than limit' do
      result1 = SubscriptionService.get_subscriptions(limit: 2)
      expect(result1[:subscriptions].length).to eq(2)
      expect(result1[:next_cursor]).to eq(subscription2.id)
      expect(result1[:previous_cursor]).to eq(subscription1.id)

      result2 = SubscriptionService.get_subscriptions(pagination_id: result1[:next_cursor], limit: 2)
      expect(result2[:subscriptions].length).to eq(1)
      expect(result2[:next_cursor]).to eq(subscription3.id)
      expect(result2[:previous_cursor]).to eq(subscription3.id)
      expect(result2[:has_more]).to be_falsey

      [result1, result2].each do |result|
        result[:subscriptions].each do |subscription|
          expect(subscription).to include(
            'work_email' => be_a(String),
            'first_name' => be_a(String),
            'last_name' => be_a(String),
            'category_name' => be_a(String)
          )
        end
      end
    end

    it 'returns paginated record when category_guids is provided and data is less than limit' do
      result = SubscriptionService.get_subscriptions(
        category_guids: [category1.guid],
        limit: 5
      )

      expect(result[:subscriptions].length).to eq(2)
      expect(result[:next_cursor]).to eq(subscription3.id)
      expect(result[:previous_cursor]).to eq(subscription1.id)
      expect(result[:has_more]).to be_falsey
      
      result[:subscriptions].each do |subscription|
        expect(subscription).to include(
          'work_email' => be_a(String),
          'first_name' => be_a(String),
          'last_name' => be_a(String),
          'category_name' => eq(category1.name)
        )
      end
    end

    it 'returns paginated record when category_guids is provided and data is more than limit' do
      # Create additional customers and subscriptions for category1
      customer4 = create(:customer)
      customer5 = create(:customer)
      customer6 = create(:customer)
      customer7 = create(:customer)
      subscription4 = create(:subscription, customer: customer4, category: category1)
      subscription5 = create(:subscription, customer: customer5, category: category1)
      subscription6 = create(:subscription, customer: customer6, category: category1)
      subscription7 = create(:subscription, customer: customer7, category: category1)

      result1 = SubscriptionService.get_subscriptions(category_guids: [category1.guid], limit: 3)
      expect(result1[:subscriptions].length).to eq(3)
      expect(result1[:previous_cursor]).to eq(subscription1.id)
      expect(result1[:next_cursor]).to eq(subscription4.id)
      expect(result1[:has_more]).to be_truthy

      result2 = SubscriptionService.get_subscriptions(
        category_guids: [category1.guid],
        pagination_id: result1[:next_cursor],
        limit: 3
      )
      expect(result2[:subscriptions].length).to eq(3)
      expect(result2[:previous_cursor]).to eq(subscription5.id)
      expect(result2[:next_cursor]).to eq(subscription7.id)
      expect(result2[:has_more]).to be_falsey

      [result1, result2].each do |result|
        result[:subscriptions].each do |subscription|
          expect(subscription).to include(
            'work_email' => be_a(String),
            'first_name' => be_a(String),
            'last_name' => be_a(String),
            'category_name' => eq(category1.name)
          )
        end
      end
    end

    it 'should be able to navigate forward and backward' do
      # Create additional customers and subscriptions for category1
      customer4 = create(:customer)
      customer5 = create(:customer)
      customer6 = create(:customer)
      customer7 = create(:customer)
      subscription4 = create(:subscription, customer: customer4, category: category1)
      subscription5 = create(:subscription, customer: customer5, category: category1)
      subscription6 = create(:subscription, customer: customer6, category: category1)
      subscription7 = create(:subscription, customer: customer7, category: category1)

      result1 = SubscriptionService.get_subscriptions(category_guids: [category1.guid], limit: 3)
      expect(result1[:subscriptions].length).to eq(3)
      expect(result1[:previous_cursor]).to eq(subscription1.id)
      expect(result1[:next_cursor]).to eq(subscription4.id)

      result2 = SubscriptionService.get_subscriptions(
        category_guids: [category1.guid],
        pagination_id: result1[:next_cursor],
        limit: 3
      )
      expect(result2[:subscriptions].length).to eq(3)
      expect(result2[:previous_cursor]).to eq(subscription5.id)
      expect(result2[:next_cursor]).to eq(subscription7.id)

      result3 = SubscriptionService.get_subscriptions(
        category_guids: [category1.guid],
        pagination_id: result2[:previous_cursor],
        pagination_direction: 'backward',
        limit: 3
      )

      expect(result3[:subscriptions].length).to eq(3)
      expect(result3[:previous_cursor]).to eq(subscription1.id)
      expect(result3[:next_cursor]).to eq(subscription4.id)
    end
  end
end
