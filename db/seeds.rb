# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?

# ActiveRecord::Base.connection.execute("TRUNCATE TABLE order_items, orders, payments RESTART IDENTITY CASCADE")


if Rails.env.production?
    #Admin
    admin_user = AdminUser.find_by(email: 'joshiaman112@gmail.com')
    AdminUser.create(email: 'joshiaman112@gmail.com', password: 'password', password_confirmation: 'password') if admin_user.nil?

    # Category
    Category.find_or_create_by(name: 'Mobile')
    Category.find_or_create_by(name: 'Headphones')
    Category.find_or_create_by(name: 'Accessories')
    Category.find_or_create_by(name: 'TV')
    Category.find_or_create_by(name: 'Laptop')
    Category.find_or_create_by(name: 'Smart Watch')

    #Vendor
    Vendor.find_or_create_by(name: 'EComiq', email: 'support@ecomic.ca', phone_number: '753-951-456', address: 'Ecomiq World Pvt Ltd, Oshawa')
    Vendor.find_or_create_by(name: 'Aapple', email: 'applesupport@gmail.com', phone_number: '123-456-789', address: 'Apple House, Toronto')
    Vendor.find_or_create_by(name: 'Samsung', email: 'Support_samsungcanada@gmailca', phone_number: '123-456-789', address: 'Sasung House, Toronto')
    Vendor.find_or_create_by(name: 'One Plus', email: 'onplussupport@oneplus.ca', phone_number: '123-456-789', address: 'One Electronics Pvt Ltd, Oshawa, Ontario')
    Vendor.find_or_create_by(name: 'TechMart', email: 'sales@techmart.ca', phone_number: '987-654-321', address: 'techmartsupport@tekmart.ca')
end
