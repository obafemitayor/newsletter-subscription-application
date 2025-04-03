class AddGuidToTables < ActiveRecord::Migration[7.1]
  def change
    add_column :customers, :guid, :string, limit: 36
    add_column :categories, :guid, :string, limit: 36
    add_column :subscriptions, :guid, :string, limit: 36

    add_index :customers, :guid, unique: true
    add_index :categories, :guid, unique: true
    add_index :subscriptions, :guid, unique: true
  end
end
