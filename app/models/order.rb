class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_one :payment, dependent: :destroy
  has_many :reviews, dependent: :destroy

  accepts_nested_attributes_for :order_items

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "id", "id_value", "payment_status", "status", "total_price", "updated_at", "user_id"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["order_items", "payment", "reviews", "user"]
  end

  STATES = {
    pending: 'pending',
    confirmed: 'confirmed',
    shipped: 'shipped',
    completed: 'completed',
    incomplete: 'incomplete',
    cancelled: 'cancelled'
  }

  PAYMENT_STATUSES = {
    unpaid: 'unpaid',
    paid: 'paid'
  }

  # Set initial statuses
  after_initialize :set_initial_state, if: :new_record?

  private
  def set_initial_state
    self.status ||= STATES[:confirmed]
    self.payment_status ||= PAYMENT_STATUSES[:unpaid]
  end

  # Calculate the total price of the order based on the associated order items
  def calculate_total_price
    self.total_price = order_items.sum { |item| item.quantity * item.product.price }
  end
  
  # Confirm order after payment completion
  def confirm_order
    update(status: STATES[:confirmed], payment_status: PAYMENT_STATUSES[:paid])
  end
end
