# app/models/review.rb
class Review < ApplicationRecord
  belongs_to :product
  belongs_to :user
  belongs_to :order

  # Validations
  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :message, presence: true, length: { maximum: 500 }
end
