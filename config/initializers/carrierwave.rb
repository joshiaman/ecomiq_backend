CarrierWave.configure do |config|
    config.fog_credentials = {
    provider:              'AWS',
    aws_access_key_id:     "AKIA2S2Y4DL6QW6UC3MV",
    aws_secret_access_key: "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",
    use_iam_profile:       true,
    region:                'ca-central-1'
    }

    config.fog_directory  = 'ecomiq-prod'
    config.fog_public     = false
    config.fog_attributes = { cache_control: "public, max-age=#{365.days.to_i}" }
end
  