Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, Rails.application.secrets.app_id, Rails.application.secrets.app_secret,
    #select permissions from docs: https://developers.facebook.com/docs/facebook-login/permissions
    scope: 'email, read_insights, manage_pages, publish_pages', display: 'page'
end