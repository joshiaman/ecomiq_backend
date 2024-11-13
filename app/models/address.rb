class Address < ApplicationRecord
  belongs_to :user

  validates :street, :city, :state, :zip, :country, presence: true

  def self.ransackable_attributes(auth_object = nil)
    ["city", "country", "created_at", "id", "state", "street", "updated_at", "user_id", "zip"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["user"]
  end
end
