class Category < ApplicationRecord
    has_many :category_vendors
    has_many :vendors, through: :category_vendors
    has_many :products
  
    validates :name, presence: true, uniqueness: true

    def self.ransackable_associations(auth_object = nil)
        ["category_vendors", "vendors", "products"]
    end

    def self.ransackable_attributes(auth_object = nil)
        ["created_at", "description", "id", "name", "updated_at"]
    end
  end
  