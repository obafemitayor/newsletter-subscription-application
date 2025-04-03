# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CategoryService do
  describe '.list_categories' do
    let!(:category1) { create(:category, name: 'A Category') }
    let!(:category2) { create(:category, name: 'B Category') }
    let!(:deleted_category) { create(:category, deleted_at: Time.current) }

    it 'returns active categories with guid and name' do
      categories = CategoryService.list_categories
      expected_categories = [
        { 'guid' => category1.guid, 'name' => category1.name },
        { 'guid' => category2.guid, 'name' => category2.name }
      ]
      expect(categories).to eq(expected_categories)
      expect(categories.map { |c| c['guid'] }).not_to include(deleted_category.guid)
    end
  end
end
