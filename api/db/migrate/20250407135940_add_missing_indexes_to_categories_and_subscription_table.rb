class AddMissingIndexesToCategoriesAndSubscriptionTable < ActiveRecord::Migration[7.1]
  def change
    add_index :categories, :name, unique: true
    add_index :subscriptions, [:customer_id, :category_id], unique: true, name: 'index_subscriptions_on_customer_and_category'
  end
end
