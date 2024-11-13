class OrderItem < ApplicationRecord
  belongs_to :order, optional: true
  belongs_to :product
  belongs_to :user

  before_create :check_inventory


  def price
    product.price
  end

  def check_inventory
    if quantity > product.sku
      errors.add(:base, "Insufficient stock for product '#{product.name}'")
      throw(:abort)
    end
  end

  def adjust_inventory
    product.decrement!(:sku, quantity)
  end
end

