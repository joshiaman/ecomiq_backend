# config/initializers/paypal.rb
PayPal::SDK.configure(
  mode: 'sandbox', # "sandbox" or "live"
  client_id: ENV['PAYPAL_CLIENT_ID'],
  client_secret: ENV['PAYPAL_SECRET_ID']
)
