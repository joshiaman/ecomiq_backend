class AddProductImageToProducts < ActiveRecord::Migration[7.2]
  def change
    add_column :products, :product_image, :string
  end
end
