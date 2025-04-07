# frozen_string_literal: true

module V1
  class SubscriptionsController < ApplicationController
    def index
      validate_query_string_parameters

      subscriptions = SubscriptionService.get_subscriptions(
        category_guids: Array.wrap(params[:category_guids]).presence,
        pagination_id: params[:pagination_id]&.to_i,
        pagination_direction: params[:pagination_direction] || 'forward',
        limit: (params[:limit] || 10).to_i
      )

      render json: subscriptions
    rescue ArgumentError => e
      render json: { error: e.message }, status: :bad_request
    end

    def create
      validate_create_subscription_payload

      SubscriptionService.create_subscription(
        work_email: params[:work_email],
        first_name: params[:first_name],
        last_name: params[:last_name],
        category_guids: params[:category_guids]
      )

      head :created
    rescue ActionController::ParameterMissing, ArgumentError => e
      render json: { error: e.message }, status: :bad_request
    end

    private

    def validate_create_subscription_payload
      params.require(:first_name)
      params.require(:last_name)
      params.require(:work_email)
      params.require(:category_guids)

      unless params[:work_email].match?(URI::MailTo::EMAIL_REGEXP)
        raise ArgumentError, 'work_email must be a valid email address'
      end

      return unless params[:category_guids].empty?

      raise ActionController::ParameterMissing.new('category_guids cannot be empty')
    end

    def validate_query_string_parameters
      if params[:pagination_id].present? && params[:pagination_id].to_i.zero?
        raise ArgumentError, 'pagination_id must be numeric'
      end

      raise ArgumentError, 'limit must be numeric' if params[:limit].present? && params[:limit].to_i.zero?

      if params[:category_guids] && ![*params[:category_guids]].all?(&:present?)
        raise ArgumentError, 'category_guids must be a list of non-empty strings'
      end

      if params[:pagination_direction].present? && params[:pagination_direction] != 'forward' && params[:pagination_direction] != 'backward'
        raise ArgumentError, 'pagination_direction must either be forward or backward'
      end
    end
  end
end
