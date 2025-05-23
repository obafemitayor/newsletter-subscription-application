class CreateSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :subscriptions do |t|
      t.references :customer, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
