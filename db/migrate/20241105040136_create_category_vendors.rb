class CreateCategoryVendors < ActiveRecord::Migration[7.2]
  def change
    create_table :category_vendors do |t|
      t.references :category, null: false, foreign_key: true
      t.references :vendor, null: false, foreign_key: true

      t.timestamps
    end
  end
end
