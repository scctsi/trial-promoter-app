require "csv"

class TwitterRepliesAggregator
  def initialize
    secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
    Setting[:twitter]=secrets['twitter']
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key = Setting[:twitter]["consumer_key"]
      config.consumer_secret = Setting[:twitter]["consumer_secret"]
      config.access_token = Setting[:twitter]["access_token"]
      config.access_token_secret = Setting[:twitter]["access_token_secret"]
    end
  end

  def get_account(account)
    return @client.user(account).name
  end

  def get_tweets(since_id = nil)
    options = {}
    options[:since_id] = since_id unless since_id.nil?
    tweets = @client.home_timeline(options)
    CSV.open("twitter_replies.csv", "w+", :headers => ["Date of tweet", "Tweet text", "Id", "Hashtags"], :write_headers => true) do |csv|
      tweets.each do |tweet|
        hashtags = []
        hashtags = tweet.hashtags if tweet.entities?
          csv << [tweet.created_at, tweet.text, tweet.id, hashtags]
      end
    end
  end
  
  # private
  
  # def collect_with_since_id(collection=[], since_id=nil, &block)
  #   response = yield(since_id)
  #   collection += response
  #   response.empty? ? collection.flatten : collect_with_since_id(collection, response.last.id - 1, &block)
  # end
  
  # def client.get_recent_tweets(user)
  #   collect_with_since_id do |since_id|
  #     options = {count: 200, include_rts: true}
  #     options[:since_id] = since_id unless since_id.nil?
  #     user_timeline(user, options)
  #   end
  # end
end