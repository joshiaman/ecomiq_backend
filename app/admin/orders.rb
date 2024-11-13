# app/admin/orders.rb
ActiveAdmin.register Order do
    actions :all, except: [:new, :destroy]  # Disable new and destroy actions
  
    permit_params :user_id, :total_payment, :payment_status
  
    # Index page
    index do
      selectable_column
      id_column
      column :user
      column :total_payment
      column :payment_status
      column :created_at
      actions
    end
  
    # Show page
    show do
      attributes_table do
        row :id
        row :user
        row :total_payment
        row :payment_status
        row :created_at
        row :updated_at
      end
  
      panel "Order Items" do
        table_for order.order_items do
          column :product do |item|
            item.product.name  # Display product name
          end
          column :quantity
          column :price
          column :total_price do |item|
            item.quantity * item.price  # Total price per item
          end
        end
      end
  
      panel "Payment Information" do
        attributes_table_for order.payment do
          row :payment_method
          row :payment_status
          row :transaction_id
          row :processed_at
        end
      end
    end
  
    # Filters for orders
    filter :user, collection: -> { User.distinct.pluck(:first_name) }
    filter :total_payment
    filter :payment_status, as: :select, collection: ['Paid', 'Pending', 'Failed']
    filter :created_at
    filter :id  #, as: :number
  end
  