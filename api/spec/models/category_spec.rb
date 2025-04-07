require 'rails_helper'

RSpec.describe Category, type: :model do
  describe 'associations' do
    it { should have_many(:subscriptions).dependent(:destroy) }
    it { should have_many(:customers).through(:subscriptions) }
  end

  describe 'CRUD operations' do
    it 'can be created with valid attributes' do
      category = build(:category)
      expect(category.save).to be true
    end

    it 'cannot be created with invalid attributes' do
      category = Category.new # Empty attributes
      expect(category.save).to be false
      expect(category.errors.full_messages).to include(
        "Name can't be blank"
      )
    end

    it 'cannot be created with duplicate name' do
      create(:category, name: 'Technology')
      new_category = build(:category, name: 'Technology')
      expect(new_category.save).to be false
      expect(new_category.errors.full_messages).to include(
        'Name has already been taken'
      )
    end

    it 'can be updated with valid attributes' do
      category = create(:category)
      expect(category.update(name: 'New Category Name')).to be true
      expect(category.reload.name).to eq('New Category Name')
    end

    it 'cannot be updated with invalid attributes' do
      category = create(:category)
      expect(category.update(name: '')).to be false
      expect(category.errors.full_messages).to include(
        "Name can't be blank"
      )
    end

    it 'can be soft deleted' do
      category = create(:category)
      category.soft_delete
      expect(category.deleted_at).to be_present
    end
  end
end
