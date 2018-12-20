Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
  provider :twitter, Rails.application.secrets.TWITTER_KEY, Rails.application.secrets.TWITTER_SECRET
end