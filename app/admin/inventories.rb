# app/admin/inventories.rb
ActiveAdmin.register Inventory do
    permit_params :product_id, :quantity
  
    index do
      selectable_column
      id_column
      column :product
      column :stock
      actions
    end
  
    form do |f|
      f.inputs do
        f.input :product
        f.input :quantity
      end
      f.actions
    end
  end
  