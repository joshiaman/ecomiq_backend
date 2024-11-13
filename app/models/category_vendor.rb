class CategoryVendor < ApplicationRecord
  belongs_to :category
  belongs_to :vendor

  def self.ransackable_attributes(auth_object = nil)
    ["category_id", "created_at", "id", "updated_at", "vendor_id"]
  end
end
