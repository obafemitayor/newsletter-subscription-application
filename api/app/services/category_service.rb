# frozen_string_literal: true

class CategoryService
  class << self
    # NOTE: Pagination is intentionally omitted here because:
    # 1. Most subscription-based websites maintain a limited set of categories.
    #    I have not seen any website with more than 20 categories for a subscription.
    # 2. The data size doesn't warrant the complexity of pagination.
    def list_categories
      Category.where(deleted_at: nil).select(:guid, :name).as_json(only: [:guid, :name])
    end
  end
end
