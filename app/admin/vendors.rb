# app/admin/vendors.rb
ActiveAdmin.register Vendor do
    permit_params :name, :email, :phone_number, :address, category_ids: []
  
    index do
      selectable_column
      id_column
      column :name
      column :email
      column :phone_number
      column :products_count do |vendor|
        vendor.products.count
      end
      column :categories do |vendor|
        vendor.categories.map(&:name).join(", ")
      end
      actions
    end
  
    form do |f|
      f.inputs do
        f.input :name
        f.input :email
        f.input :phone_number
        f.input :address
        f.input :categories, as: :check_boxes, collection: Category.all
      end
      f.actions
    end
  end
  