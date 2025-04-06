class SeedCategories < ActiveRecord::Migration[7.0]
  def up
    categories = [
      "Product updates",
      "Articles and market insights",
      "Case studies",
      "Technology trends",
      "Best practices"
    ]

    categories.each do |name|
      Category.create!(name: name)
    end
  end

  def down
    Category.where(name: [
      "Product updates",
      "Articles and market insights",
      "Case studies",
      "Technology trends",
      "Best practices"
    ]).delete_all
  end
end
