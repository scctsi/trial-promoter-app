Bitly.configure do |config|
  config.api_version = 3
  config.access_token = Figaro.env.bitly_access_token
end
