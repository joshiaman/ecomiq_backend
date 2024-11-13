# app/admin/users.rb

ActiveAdmin.register User do
  menu parent: "User Details"
  permit_params :first_name, :last_name, :date_of_birth, :email, :password, :password_confirmation, addresses_attributes: [:id, :street, :city, :state, :zip, :country, :_destroy]

  # Define Ransack filters for the User model
  filter :email_cont, label: "Email Contains"
  # Filters for associated model (Addresses)
  filter :addresses_street_cont, as: :string, label: "Address Street Contains"
  filter :addresses_city_cont, as: :string, label: "City Contains"
  filter :addresses_state_eq, as: :select, label: "State", collection: -> { Address.distinct.pluck(:state) }
  filter :addresses_zip_eq, as: :string, label: "Zip Code"
  filter :addresses_country_eq, as: :select, label: "Country", collection: -> { Address.distinct.pluck(:country) }

  index do
    selectable_column
    column :id
    column :first_name
    column :last_name
    column :email
    column "Addresses" do |user|
      user.addresses.map { |address| "#{address.street}, #{address.city}, #{address.state}, #{address.zip}, #{address.country}" }.join("<br>").html_safe
    end
    column :created_at
    column :updated_at
  end
  
  # Show page configuration
  show do
    attributes_table do
      row :first_name
      row :last_name
      row :email
      row :created_at
      row :updated_at
    end
  
    # Panel to display associated addresses
    panel "Addresses" do
      table_for user.addresses do
        column :street
        column :city
        column :state
        column :zip
        column :country
  
        column "Actions" do |address|
          # link_to("View", admin_address_path(address)) + " | " +
          # link_to("Edit", edit_admin_address_path(address)) + " | " +
          link_to("Delete", admin_address_path(address), method: :delete, data: { confirm: "Are you sure?" })
        end
      end
    end
  end
  

  # Form configuration to create or edit user and their addresses
  form do |f|
    f.inputs "User Details" do
      f.input :first_name
      f.input :last_name
      f.input :date_of_birth, as: :datepicker
      f.input :email
      f.input :password
      f.input :password_confirmation
    end

    f.inputs "Addresses" do
      f.has_many :addresses, allow_destroy: true, new_record: true do |a|
        a.input :street
        a.input :city
        a.input :state
        a.input :zip
        a.input :country, as: :string
      end
    end

    f.actions
  end
end
