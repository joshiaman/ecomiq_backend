# app/admin/products.rb
ActiveAdmin.register Product do
    permit_params :name, :description, :price, :category_id, :vendor_id, :sku, :product_image, :remove_product_image
  
    index do
      selectable_column
      id_column
      column 'Image' do |product|
        if product.product_image.present?
          image_tag product.product_image.url, size: "100x100" # Use project.image.url to get the file URL
        else
          "No Image"
        end
      end
      column :name
      column :price
      column :category
      column :vendor
      column "Inventory" do |product|
        product&.in_stock? || 'Not Available'
      end
      actions
    end
  
    form do |f|
      f.inputs do
        f.input :name
        f.input :description
        f.input :price
        f.input :category
        f.input :vendor
        f.input :sku
        if f.object.product_image.present?
            f.input :product_image, :as => :file, :hint => image_tag(f.object.product_image.url, size: "100x100")
            f.input :remove_product_image, as: :boolean, label: 'Remove Image'
        else
            f.input :product_image, as: :file
        end
      end
      f.actions
    end
  end
  