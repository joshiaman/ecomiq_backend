class AllowNullOrderIdInOrderItems < ActiveRecord::Migration[7.2]
  def change
    change_column_null :order_items, :order_id, true
  end
end
