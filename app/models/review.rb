# app/models/review.rb
class Review
  include Mongoid::Document
  include Mongoid::Timestamps

  field :rating, type: Integer
  field :message, type: String

  # Foreign keys as plain fields
  field :product_id, type: Integer
  field :user_id, type: Integer
  field :order_id, type: Integer

  # belongs_to :product, foreign_key: :product_id
  # belongs_to :user, foreign_key: :user_id
  # belongs_to :order, foreign_key: :order_id

  # Validations
  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :message, presence: true, length: { maximum: 500 }
end
