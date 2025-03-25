# CarrierWave.configure do |config|
#     config.storage = :fog
#     config.fog_provider = 'fog/aws'
  
#     config.fog_credentials = {
#       provider:              'AWS',
#       aws_access_key_id:     "AKIA2S2Y4DL6QW6UC3MV",
#       aws_secret_access_key: "63jePkU2qqUcfFxcdbzJZxfYJvbRgbPubqgIqdr9",
#       region:                'ca-central-1'
#     }
  
#     config.fog_directory  = 'ecomiq-prod'   # Your bucket name
#     config.fog_public     = false                   # optional, makes uploads private
#     config.cache_dir      = "#{Rails.root}/tmp/uploads"  # Local cache before upload
# end

CarrierWave.configure do |config|
    config.cache_dir = "#{Rails.root}/tmp/uploads"
end
  