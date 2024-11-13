ActiveAdmin.register Address do
    menu parent: "User Details", label: "User Addresses"
    permit_params :street, :city, :state, :zip, :country

    # Show page configuration
    show do
        attributes_table do
            row :street
            row :city
            row :state
            row :zip
            row :country
        end

        panel "User Details" do
            table_for [resource.user] do
                column :first_name
                column :last_name
                column :email
                column :created_at
                column :updated_at
            end
        end
    end
    
    
  
    # Form configuration to create or edit user and their addresses
    form do |f|
        f.inputs "Addresses" do
          f.input :street
          f.input :city
          f.input :state
          f.input :zip
          f.input :country, as: :string
        end
    f.actions
    end
end
  