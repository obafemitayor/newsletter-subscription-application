require 'rails_helper'

RSpec.describe Subscription, type: :model do
  describe 'associations' do
    it { should belong_to(:customer) }
    it { should belong_to(:category) }
  end

  describe 'CRUD operations' do
    let(:customer) { create(:customer) }
    let(:category) { create(:category) }

    it 'can be created with valid attributes' do
      subscription = build(:subscription, customer: customer, category: category)
      expect(subscription.save).to be true
    end

    it 'cannot be created without customer' do
      subscription = build(:subscription, customer: nil)
      expect(subscription.save).to be false
      expect(subscription.errors.full_messages).to include(
        "Customer must exist",
        "Customer can't be blank"
      )
    end

    it 'cannot be created without category' do
      subscription = build(:subscription, customer: customer, category: nil)
      expect(subscription.save).to be false
      expect(subscription.errors.full_messages).to include(
        "Category must exist",
        "Category can't be blank"
      )
    end

    it 'cannot create duplicate subscription for same customer and category' do
      create(:subscription, customer: customer, category: category)
      duplicate = build(:subscription, customer: customer, category: category)
      expect(duplicate.save).to be false
      expect(duplicate.errors.full_messages).to include(
        "Customer already subscribed to this category"
      )
    end

    it 'can be soft deleted' do
      subscription = create(:subscription, customer: customer, category: category)
      subscription.soft_delete
      expect(subscription.deleted_at).to be_present
    end
  end

  describe 'many-to-many relationship' do
    let(:customer) { create(:customer) }
    let(:category1) { create(:category, name: 'Technology') }
    let(:category2) { create(:category, name: 'Science') }

    before do
      create(:subscription, customer: customer, category: category1)
      create(:subscription, customer: customer, category: category2)
    end

    it 'returns all categories a customer is subscribed to' do
      expect(customer.categories).to match_array([category1, category2])
    end

    it 'returns all customers subscribed to a category' do
      another_customer = create(:customer)
      create(:subscription, customer: another_customer, category: category1)
      
      expect(category1.customers).to match_array([customer, another_customer])
    end
  end
end
