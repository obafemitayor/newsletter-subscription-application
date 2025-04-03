class SeedCategories < ActiveRecord::Migration[7.0]
  def up
    categories = [
      "Product updates",
      "Articles and market insights",
      "Case studies",
      "Industry news",
      "Technology trends",
      "Best practices",
      "Tips and tutorials",
      "Customer success stories",
      "Company announcements",
      "Event notifications",
      "Research reports",
      "Developer resources",
      "Security updates",
      "Feature highlights",
      "Community spotlight"
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
      "Industry news",
      "Technology trends",
      "Best practices",
      "Tips and tutorials",
      "Customer success stories",
      "Company announcements",
      "Event notifications",
      "Research reports",
      "Developer resources",
      "Security updates",
      "Feature highlights",
      "Community spotlight"
    ]).delete_all
  end
end
