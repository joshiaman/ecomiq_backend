# config/initializers/paypal.rb
PayPal::SDK.configure(
  mode: 'sandbox', # "sandbox" or "live"
  client_id: "AdxNKa1BCIwnicc9p1fCYGOH1bUYSbnDJNfFSkxt3HKhoEwgTrETaYWBP1lR9dG86NlLugIO8PsMMB0Z",
  client_secret: "EKWHe0nt2A0Di_Dn0UlQAG4NEUc2bSEzHM7vKZu0cUqHLZCuHxAkvt9KwiDGBhx0Mkbr_LV81y6Kcyzt"
)
