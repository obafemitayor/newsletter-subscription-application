class SeedGuidForExistingCategories < ActiveRecord::Migration[7.1]
  def up
    execute <<-SQL
      UPDATE categories 
      SET guid = UUID() 
      WHERE guid IS NULL
    SQL
  end

  def down
    # No need to rollback as we don't want to remove GUIDs
  end
end
