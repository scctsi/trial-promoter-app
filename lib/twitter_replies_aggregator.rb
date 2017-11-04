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

  def get_tweets
    tweets = @client.home_timeline
p tweets
    # begin
      CSV.open("twitter_replies.csv", "ab") do |csv|
        # tweets.each do |tweet|
          # all_comments = @graph.get_connections(tweet["id"], "comments", filter: 'stream')
          # begin
          #   all_comments.each do |c|
              csv << tweets
          #   end
          #   all_comments = all_comments.next_page
          # end while all_comments != nil
        # end
        # all_posts = all_posts.next_page
      end
    # end while all_posts != nil
  end
end