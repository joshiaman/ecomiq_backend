class AddPaypalOrderIdToPayments < ActiveRecord::Migration[7.2]
  def change
    add_column :payments, :paypal_order_id, :string
  end
end
