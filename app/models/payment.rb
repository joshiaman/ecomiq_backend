class Payment < ApplicationRecord
  include PayPal::SDK::REST
  belongs_to :order

  def process_paypal_payment
    uri = URI.parse("https://api-m.sandbox.paypal.com/v2/checkout/orders")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.path, {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{generate_paypal_token}"
    })

    request.body = {
      intent: "CAPTURE",
      purchase_units: [
        {
          amount: {
            currency_code: "CAD",
            value: order.total_price.to_s
          }
        }
      ]
    }.to_json

    response = http.request(request)
    data = JSON.parse(response.body) 
    if response.is_a?(Net::HTTPSuccess)
      data["id"]
    else
      nil
    end
  rescue => e
    Rails.logger.error "PayPal order creation failed: #{e.message}"
    nil
  end

  def capture_paypal_payment(paypal_order_id)
    uri = URI.parse("https://api-m.sandbox.paypal.com/v2/checkout/orders/#{paypal_order_id}/capture")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.path, {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{generate_paypal_token}"
    })

    response = http.request(request)
    data = JSON.parse(response.body)

    # "COMPLETED"
    if response.is_a?(Net::HTTPSuccess) && data["status"] == "COMPLETED"
      self.update(payment_id: data["id"])
      data["status"]
    else
      "FAILED"
    end
  rescue => e
    Rails.logger.error "PayPal order verification failed: #{e.message}"
    nil
  end

  def generate_paypal_token
    uri = URI.parse("https://api-m.sandbox.paypal.com/v1/oauth2/token")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.path)
    request.basic_auth(ENV['PAYPAL_CLIENT_ID'], ENV['PAYPAL_SECRET_KEY'])
    request.set_form_data({ grant_type: "client_credentials" })

    response = http.request(request)
    data = JSON.parse(response.body)

    data["access_token"]
  end
end
