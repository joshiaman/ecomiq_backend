class ChangeSkuToIntegerInProducts < ActiveRecord::Migration[7.2]
  def change
    change_column :products, :sku, :integer, using: 'sku::integer'
  end
end
