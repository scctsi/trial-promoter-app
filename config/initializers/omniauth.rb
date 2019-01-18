Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, Rails.application.secrets.app_id, Rails.application.secrets.app_secret,
    scope: 'email, read_insights', display: 'popup'
end