class CreateCustomers < ActiveRecord::Migration[7.1]
  def change
    create_table :customers do |t|
      t.string :first_name
      t.string :last_name
      t.string :work_email
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :customers, :work_email, unique: true
  end
end
