class Product < ApplicationRecord
  belongs_to :vendor
  belongs_to :category
  has_one :inventory, dependent: :destroy
  has_many :order_items, dependent: :destroy

  mount_uploader :product_image, ProductImageUploader

  def self.ransackable_associations(auth_object = nil)
    ["category", "vendor", "inventory", "order_items"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["category_id", "created_at", "description", "id", "name", "price", "sku", "updated_at", "vendor_id", "product_image", "order_items_id"]
  end

  def in_stock?
    self.sku.to_i > 0
  end

  def availability
    sku.to_i <= 0 ? "Out of Stock" : "In Stock"
  end 

  def avg_product_rating
    ratings = Review.where(product_id: self.id).pluck(:rating)
    if ratings.any?
      ratings.sum.to_f / ratings.size
    else
      0.0
    end
  end

  def reviews
    Review.where(product_id: id)
  end
end
