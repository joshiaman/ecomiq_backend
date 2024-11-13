class AddUserIdToOrderItems < ActiveRecord::Migration[7.2]
  def change
    add_reference :order_items, :user, foreign_key: true
  end
end