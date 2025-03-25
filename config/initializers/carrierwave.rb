CarrierWave.configure do |config|
    if Rails.env.production?
      config.storage = :fog
      config.fog_provider = 'fog/aws'
  
      config.fog_credentials = {
        provider:              'AWS',
        aws_access_key_id:     "AKIA2S2Y4DL6QW6UC3MV",
        aws_secret_access_key: "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",
        region:                'ca-central-1'
      }
  
      config.fog_directory  = 'ecomiq-prod'
      config.fog_public     = false
      config.cache_dir      = "#{Rails.root}/tmp/uploads"
    else
      config.storage = :file
    end
end
  