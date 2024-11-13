class AdminUser < ApplicationRecord
  devise :database_authenticatable, 
         :recoverable, :rememberable, :validatable

  # Define the ransackable_attributes method
  def self.ransackable_attributes(auth_object = nil)
    %w[id email created_at updated_at] # Add any attributes you want to make searchable
  end
end
