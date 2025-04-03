# frozen_string_literal: true

module V1
  class CategoriesController < ApplicationController
    def index
      categories = CategoryService.list_categories
      render json: { categories: categories }
    end
  end
end
