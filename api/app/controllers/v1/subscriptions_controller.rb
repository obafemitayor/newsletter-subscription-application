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

      raise ActionController::ParameterMissing, 'category_guids cannot be empty'
    end

    def validate_query_string_parameters
      validate_pagination_id
      validate_limit
      validate_category_guids
      validate_pagination_direction
    end

    def validate_pagination_id
      return unless params[:pagination_id].present? && params[:pagination_id].to_i.zero?

      raise ArgumentError, 'pagination_id must be numeric'
    end

    def validate_limit
      return unless params[:limit].present? && params[:limit].to_i.zero?

      raise ArgumentError, 'limit must be numeric'
    end

    def validate_category_guids
      return unless params[:category_guids] && ![*params[:category_guids]].all?(&:present?)

      raise ArgumentError, 'category_guids must be a list of non-empty strings'
    end

    def validate_pagination_direction
      return if params[:pagination_direction].blank?

      return if ['forward', 'backward'].include?(params[:pagination_direction])

      raise ArgumentError, 'pagination_direction must either be forward or backward'
    end
  end
end
