class ChangeTotalPriceInOrders < ActiveRecord::Migration[7.2]
  def change
    change_column :orders, :total_price, :decimal, precision: 10, scale: 2
  end
end
