class Twitter
  # This class is a facade to the twitter gem
  @client = Twitter::REST::Client.new do |config|
    config.consumer_key        = Setting['twitter_consumer_key']
    config.consumer_secret     = Setting['twitter_consumer_secret']
    config.access_token        = Setting['twitter_access_token']
    config.access_token_secret = Setting['twitter_access_secret']
  end
  
  
end