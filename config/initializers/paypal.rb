# config/initializers/paypal.rb
PayPal::SDK.configure(
  mode: ENV["PAYPAL_MODE"], # "sandbox" or "live"
  client_id: ENV["PAYPAL_CLIENT_ID"],
  client_secret: ENV["PAYPAL_CLIENT_SECRET"]
)
