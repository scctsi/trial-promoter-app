require "csv"

class TwitterEngagementsAggregator
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

  def get_comments
    tweets = get_all_mentions_for_a_handle
    comments = []

    tweets.each do |tweet|
      comment = Comment.find_or_create_by(social_media_comment_id: tweet.id)
      comment.comment_text = tweet.text
      comment.commentator_username = tweet.user.name
      comment.commentator_id = tweet.user.id
      comment.comment_date = tweet.created_at
      comment.parent_tweet_id = tweet.in_reply_to_status_id
      
      parent_tweet = get_parent_tweet_object(comment.parent_tweet_id)
      ancestor_tweet = get_ancestor(parent_tweet)
      comment.message = Message.find_by_alternative_identifier(ancestor_tweet.id) || Message.find_by_alternative_identifier(parent_tweet.text.squish)

      comments << comment
    end
    return comments
  end
  
  def get_ancestor(parent_tweet)
    # If 'in_reply_to_status_id' is nil, then the tweet is the ancestor node; otherwise, get the parent id of that tweet
    while parent_tweet.in_reply_to_status_id?
      parent_tweet = get_parent_tweet_object(parent_tweet.in_reply_to_status_id)
    end
    return parent_tweet
  end
  
  def get_mentions
    return @client.mentions_timeline
  end

  def get_parent_tweet_object(tweet_id)
    return @client.status(tweet_id)
  end

  def collect_with_max_id(collection = [], since_id = nil, &block)
    response = yield(since_id)
    collection += response
    response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
  end
  
  def get_all_tweets_for_a_handle(handle)
    begin
      collect_with_max_id do |max_id|
        options = {count: 200, include_rts: true}
        options[:max_id] = max_id unless max_id.nil?
        @client.user_timeline(handle, options)
      end
    rescue Twitter::Error::TooManyRequests => error
      sleep error.rate_limit.reset_in + 1
      retry
    end
  end
  
  def get_all_mentions_for_a_handle
    begin
      @client.mentions_timeline
    rescue Twitter::Error::TooManyRequests => error
      sleep error.rate_limit.reset_in + 1
      retry
    end
  end  
  
  def get_all_direct_messages_for_a_handle
   return @client.direct_messages
  end
end