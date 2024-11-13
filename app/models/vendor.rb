class Vendor < ApplicationRecord
    has_many :category_vendors, dependent: :destroy
    has_many :categories, through: :category_vendors, dependent: :destroy
    has_many :products, dependent: :destroy
  
    validates :name, :email, presence: true
    validates :email, uniqueness: true

    def self.ransackable_attributes(auth_object = nil)
        ["address", "created_at", "email", "id", "name", "phone_number", "updated_at"]
    end

    def self.ransackable_associations(auth_object = nil)
        ["categories", "category_vendors", "products"]
    end
end
  