require 'rails_helper'

RSpec.describe Customer, type: :model do
  describe 'associations' do
    it { should have_many(:subscriptions).dependent(:destroy) }
    it { should have_many(:categories).through(:subscriptions) }
  end

  describe 'CRUD operations' do
    it 'can be created with valid attributes' do
      customer = build(:customer)
      expect(customer.save).to be true
    end

    it 'cannot be created with invalid attributes' do
      customer = Customer.new # Empty attributes
      expect(customer.save).to be false
      expect(customer.errors.full_messages).to include(
        "First name can't be blank",
        "Last name can't be blank",
        "Work email can't be blank"
      )
    end

    it 'cannot be created with duplicate email' do
      create(:customer, work_email: 'test@example.com')
      new_customer = build(:customer, work_email: 'test@example.com')
      expect(new_customer.save).to be false
      expect(new_customer.errors.full_messages).to include(
        'Work email has already been taken'
      )
    end

    it 'can be updated with valid attributes' do
      customer = create(:customer)
      expect(customer.update(first_name: 'Jane')).to be true
      expect(customer.reload.first_name).to eq('Jane')
    end

    it 'cannot be updated with invalid attributes' do
      customer = create(:customer)
      expect(customer.update(first_name: '')).to be false
      expect(customer.errors.full_messages).to include(
        "First name can't be blank"
      )
    end

    it 'can be soft deleted' do
      customer = create(:customer)
      customer.soft_delete
      expect(customer.deleted_at).to be_present
    end
  end
end
