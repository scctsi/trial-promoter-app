require "csv"

class TwitterRepliesAggregator
  def initialize(experiment)
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key = experiment.settings(:twitter).consumer_key
      config.consumer_secret = experiment.settings(:twitter).consumer_secret
      config.access_token = experiment.settings(:twitter).access_token
      config.access_token_secret = experiment.settings(:twitter).access_token_secret
    end
  end

  def get_account_name(handle)
    return @client.user(handle).name
  end

  def get_comments
    mentions = get_all_mentions
    comments = []

    mentions.each do |mention|
      comment = Comment.find_or_create_by(social_media_comment_id: mention.id)
      comment.comment_text = mention.text
      comment.commentator_username = mention.user.name
      comment.commentator_id = mention.user.id
      comment.comment_date = mention.created_at
      comment.parent_tweet_id = mention.in_reply_to_status_id
      
      if !(comment.parent_tweet_id.nil?)
        comment.message = Message.find_by_alternative_identifier(comment.parent_tweet_id)
      end

      comment.save
      comments << comment
    end
    
    return comments
  end
  
  def get_root_tweet(tweet)
    root_tweet = tweet
    
    # If 'in_reply_to_status_id' is nil, then the tweet is the ancestor node; otherwise, get the parent id of that tweet
    while root_tweet.in_reply_to_status_id.nil?
      root_tweet = get_parent_tweet(root_tweet.in_reply_to_status_id)
    end
    
    return root_tweet
  end
  
  # def get_mentions
  #   return @client.mentions_timeline
  # end

  def get_tweet(tweet_id)
    return @client.status(tweet_id)
  end

  def collect_with_max_id(collection = [], since_id = nil, &block)
    response = yield(since_id)
    collection += response
    response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
  end
  
  def get_all_tweets(handle)
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
  
  def get_all_mentions
    begin
      options = {count: 200}
      @client.mentions_timeline(options)
    rescue Twitter::Error::TooManyRequests => error
      sleep error.rate_limit.reset_in + 1
      retry
    end
  end  
end