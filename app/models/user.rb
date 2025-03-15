# app/models/user.rb
class User < ApplicationRecord
    has_secure_password
    validates :email, presence: true, uniqueness: true

    has_many :addresses, dependent: :destroy
    has_many :orders, dependent: :destroy
    has_many :order_items, dependent: :destroy
    has_many :reviews, dependent: :destroy
    accepts_nested_attributes_for :addresses, allow_destroy: true

    def self.ransackable_attributes(auth_object = nil)
        ["created_at", "date_of_birth", "email", "first_name", "id", "last_name", "password_digest", "updated_at"]
    end

    def self.ransackable_associations(auth_object = nil)
        ["addresses"]
      end

    # Method to generate JWT for the user
    def generate_jwt
      payload = { user_id: id, exp: 24.hours.from_now.to_i }
      JWT.encode(payload, Rails.application.credentials.secret_key_base)
    end
  
    # Class method to decode a token and return the user instance if valid
    def self.decode_jwt(token)
      decoded_token = JWT.decode(token, Rails.application.credentials.secret_key_base).first
      User.find(decoded_token["user_id"])
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      nil
    end

    def as_json(options = {})
      super(options.merge({ except: :password_digest }))
    end
  end
  