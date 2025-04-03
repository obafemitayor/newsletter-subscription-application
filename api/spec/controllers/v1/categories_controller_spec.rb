# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::CategoriesController, type: :controller do
  describe 'GET index' do
    let!(:category1) { create(:category, name: 'Category A') }
    let!(:category2) { create(:category, name: 'Category B') }
    let!(:category3) { create(:category, name: 'Category C') }

    it 'returns all active categories' do
      get :index
      expect(response).to have_http_status(:ok)
      
      result = JSON.parse(response.body)
      expect(result['categories'].length).to eq(3)
      expect(result['categories']).to match_array([
        { 'guid' => category1.guid, 'name' => 'Category A' },
        { 'guid' => category2.guid, 'name' => 'Category B' },
        { 'guid' => category3.guid, 'name' => 'Category C' }
      ])
    end
  end
end
