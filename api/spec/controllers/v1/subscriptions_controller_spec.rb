# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::SubscriptionsController, type: :controller do
  describe 'Create subscription' do
    let!(:category) { create(:category) }
    let(:valid_params) do
      {
        first_name: 'John',
        last_name: 'Doe',
        work_email: 'john@example.com',
        category_guids: [category.guid]
      }
    end

    context 'with valid parameters' do
      it 'creates a new subscription' do
        post :create, params: valid_params
        expect(response).to have_http_status(:created)
      end

      it 'creates a subscription for an existing customer without subscriptions' do
        customer = create(:customer, work_email: valid_params[:work_email])
        expect do
          post :create, params: valid_params
        end.not_to change(Customer, :count)
        expect(response).to have_http_status(:created)
        expect(customer.subscriptions.count).to eq(1)
      end

      it 'creates a subscription for an existing customer when request contains ' \
         'categories the customer is already subscribed to' do
        another_category = create(:category)
        customer = create(:customer, work_email: valid_params[:work_email])
        create(:subscription, customer: customer, category: category)

        params_with_both_categories = valid_params.merge(
          category_guids: [category.guid, another_category.guid]
        )

        post :create, params: params_with_both_categories
        expect(response).to have_http_status(:created)
        expect(customer.subscriptions.count).to eq(2)
        expect(customer.subscriptions.pluck(:category_id)).to match_array([category.id, another_category.id])
      end
    end

    context 'with invalid parameters' do
      it 'returns bad request when first_name is missing' do
        post :create, params: valid_params.except(:first_name)
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns bad request when last_name is missing' do
        post :create, params: valid_params.except(:last_name)
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns bad request when work_email is missing' do
        post :create, params: valid_params.except(:work_email)
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns bad request when category_guids is empty' do
        post :create, params: valid_params.merge(category_guids: [])
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns bad request when work_email is invalid' do
        post :create, params: valid_params.merge(work_email: 'not-an-email')
        expect(response).to have_http_status(:bad_request)
        json_response = response.parsed_body
        expect(json_response['error']).to eq('work_email must be a valid email address')
      end
    end
  end

  describe 'Get subscriptions' do
    let!(:category1) { create(:category) }
    let!(:category2) { create(:category) }
    let!(:customer) { create(:customer) }

    context 'when no query parameters exist in the request' do
      before do
        15.times do |i|
          create(:subscription,
                 customer: create(:customer),
                 category: i.even? ? category1 : category2)
        end
      end

      it 'returns paginated results with default limit' do
        # Get records of first page
        get :index
        expect(response).to have_http_status(:ok)
        first_page = response.parsed_body
        expect(first_page['subscriptions'].length).to eq(10) # Default limit
        expect(first_page['has_more']).to be_truthy
        expect(first_page['previous_cursor']).to be_present
        expect(first_page['next_cursor']).to be_present

        # Get records of second page
        get :index, params: { pagination_id: first_page['next_cursor'] }
        expect(response).to have_http_status(:ok)
        second_page = response.parsed_body
        expect(second_page['subscriptions'].length).to eq(5)
        expect(second_page['subscriptions']).not_to eq(first_page['subscriptions'])
        expect(second_page['next_cursor']).to be_present
        expect(second_page['has_more']).to be_falsey
        expect(second_page['previous_cursor']).to be_present

        [first_page, second_page].each do |page|
          page['subscriptions'].each do |subscription|
            expect(subscription).to include(
              'work_email',
              'first_name',
              'last_name',
              'category_names'
            )
            expect(subscription['category_names']).to be_an(Array)
          end
        end
      end
    end

    context 'when invalid query parameters exist in the request' do
      it 'validates pagination_id is numeric' do
        get :index, params: { pagination_id: 'abc' }

        expect(response).to have_http_status(:bad_request)
        json_response = response.parsed_body
        expect(json_response['error']).to eq('pagination_id must be numeric')
      end

      it 'validates limit is numeric' do
        get :index, params: { limit: 'abc' }

        expect(response).to have_http_status(:bad_request)
        json_response = response.parsed_body
        expect(json_response['error']).to eq('limit must be numeric')
      end

      it 'validates category_guids is not an empty string' do
        get :index, params: { category_guids: '' }

        expect(response).to have_http_status(:bad_request)
        json_response = response.parsed_body
        expect(json_response['error']).to eq('category_guids must be a list of non-empty strings')
      end

      it 'validates that pagination_direction is either forward or backward' do
        get :index, params: { pagination_direction: 'abc' }

        expect(response).to have_http_status(:bad_request)
        json_response = response.parsed_body
        expect(json_response['error']).to eq('pagination_direction must either be forward or backward')
      end
    end

    context 'when valid query parameters exist in the request' do
      before do
        15.times do |i|
          create(:subscription,
                 customer: create(:customer),
                 category: i.even? ? category1 : category2)
        end
      end

      it 'returns all subscriptions when only limit exists in the query parameters and ' \
         'limit is greater than total records' do
        get :index, params: { limit: 20 }
        expect(response).to have_http_status(:ok)
        result = response.parsed_body
        expect(result['subscriptions'].length).to eq(15)
        expect(result['next_cursor']).to be_present
        expect(result['previous_cursor']).to be_present
        expect(result['has_more']).to be_falsey

        result['subscriptions'].each do |subscription|
          expect(subscription).to include(
            'work_email',
            'first_name',
            'last_name',
            'category_names'
          )
          expect(subscription['category_names']).to be_an(Array)
        end
      end

      it 'returns paginated results when limit and one category_guid exist in the query parameters' do
        # Get records of first page
        get :index, params: { limit: 5, category_guids: category1.guid }
        expect(response).to have_http_status(:ok)
        first_page = response.parsed_body
        expect(first_page['subscriptions'].length).to eq(5)
        expect(first_page['next_cursor']).to be_present
        expect(first_page['previous_cursor']).to be_present
        expect(first_page['has_more']).to be_truthy

        # Get records of second page
        get :index, params: { limit: 5, category_guids: category1.guid, pagination_id: first_page['next_cursor'] }
        expect(response).to have_http_status(:ok)
        second_page = response.parsed_body
        expect(second_page['subscriptions'].length).to eq(3)
        expect(second_page['subscriptions']).not_to eq(first_page['subscriptions'])
        expect(second_page['next_cursor']).to be_present
        expect(second_page['previous_cursor']).to be_present
        expect(second_page['has_more']).to be_falsey

        [first_page, second_page].each do |page|
          page['subscriptions'].each do |subscription|
            expect(subscription).to include(
              'work_email',
              'first_name',
              'last_name',
              'category_names'
            )
            expect(subscription['category_names']).to be_an(Array)
          end
        end
      end

      it 'returns subscriptions when limit and multiple category_guid exist in the query parameters' do
        category3 = create(:category)
        create(:subscription, customer: customer, category: category3)

        get :index, params: {
          category_guid: [category1.guid, category2.guid, category3.guid],
          limit: 20
        }
        expect(response).to have_http_status(:ok)
        result = response.parsed_body
        expect(result['subscriptions'].length).to eq(16)
        expect(result['next_cursor']).to be_present
        expect(result['previous_cursor']).to be_present
        expect(result['has_more']).to be_falsey

        result['subscriptions'].each do |subscription|
          expect(subscription).to include(
            'work_email',
            'first_name',
            'last_name',
            'category_names'
          )
          expect(subscription['category_names']).to be_an(Array)
        end
      end

      it 'returns paginated results when only category_guid exists in the query parameters' do
        get :index, params: { category_guids: category1.guid }
        expect(response).to have_http_status(:ok)
        result = response.parsed_body
        expect(result['subscriptions'].length).to eq(8)
        expect(result['next_cursor']).to be_present
        expect(result['previous_cursor']).to be_present
        expect(result['has_more']).to be_falsey

        result['subscriptions'].each do |subscription|
          expect(subscription).to include(
            'work_email',
            'first_name',
            'last_name',
            'category_names'
          )
          expect(subscription['category_names']).to be_an(Array)
        end
      end
    end

    context 'when paginating' do
      it 'should be able to paginate in both directions' do
        customer1 = create(:customer)
        customer2 = create(:customer)
        customer3 = create(:customer)
        customer4 = create(:customer)
        customer5 = create(:customer)
        customer6 = create(:customer)
        create(:subscription, customer: customer1, category: category1)
        create(:subscription, customer: customer1, category: category2)
        create(:subscription, customer: customer2, category: category1)
        create(:subscription, customer: customer2, category: category2)
        create(:subscription, customer: customer3, category: category1)
        create(:subscription, customer: customer3, category: category2)
        create(:subscription, customer: customer4, category: category1)
        create(:subscription, customer: customer4, category: category2)
        create(:subscription, customer: customer5, category: category1)
        create(:subscription, customer: customer5, category: category2)
        create(:subscription, customer: customer6, category: category1)
        create(:subscription, customer: customer6, category: category2)

        # Forward pagination
        get :index, params: { limit: 3 }
        expect(response).to have_http_status(:ok)
        result = response.parsed_body

        expect(result['subscriptions'].length).to eq(3)
        expect(result['previous_cursor']).to eq(customer1.id)
        expect(result['next_cursor']).to eq(customer3.id)
        expect(result['has_more']).to be_truthy

        # Forward pagination
        get :index, params: { limit: 3, pagination_id: result['next_cursor'] }
        expect(response).to have_http_status(:ok)
        result_two = response.parsed_body

        expect(result_two['subscriptions'].length).to eq(3)
        expect(result_two['previous_cursor']).to eq(customer4.id)
        expect(result_two['next_cursor']).to eq(customer6.id)
        expect(result_two['has_more']).to be_falsey

        # Backward pagination
        get :index, params: { limit: 3, pagination_id: result_two['previous_cursor'], pagination_direction: 'backward' }
        expect(response).to have_http_status(:ok)
        result_three = response.parsed_body

        expect(result_three['subscriptions'].length).to eq(3)
        expect(result_three['next_cursor']).to eq(customer3.id)
        expect(result_three['previous_cursor']).to eq(customer1.id)
        expect(result_three['has_more']).to be_falsey
      end
    end
  end
end
