class Inventory < ApplicationRecord
  belongs_to :product

  def self.ransackable_associations(auth_object = nil)
    ["product"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "id", "product_id", "quantity", "updated_at"]
  end
end
