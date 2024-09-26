class FacebookMetricsAggregator
  def initialize(experiment)
    Koala.config.api_version = "v2.11"
    @graph = Koala::Facebook::API.new(experiment.settings(:facebook).facebook_access_token)
    # @ad_session = FacebookAds::Session.new(access_token: Setting[:facebook_access_token])
  end

  def get_user_object
    return @graph.get_connections("me", "accounts")
  end

  def get_ads(account, name)
    return FacebookAds::AdAccount.get(account, name, @ad_session)
  end

  def get_page_token(page_id)
    page_token = @graph.get_page_access_token(page_id)
    return Koala::Facebook::API.new(page_token)
  end

  def get_post_impressions(page_id, post_id, start_date, end_date)
    page_graph = get_page_token(page_id)
    impressions = page_graph.get_connections(post_id, "insights/post_impressions", since: start_date, until: end_date)
    return impressions[0]["values"][0]["value"]
  end
  
  def get_paginated_posts(page_id, start_date = "2017-04-19", end_date = "2017-07-13")
    page_graph = get_page_token(page_id)
    return page_graph.get_connections(page_id, 'posts', since: start_date, until: end_date)
  end
  
  def get_post_metrics(page_id, post_id, start_date, end_date)
    page_graph = get_page_token(page_id)
    metrics = {}
    metrics['comments'] = get_comments(post_id)
    metrics["impressions"] = get_impressions(page_id, post_id, start_date, end_date)
    metrics['likes'] = get_likes(page_graph, post_id) 
    metrics['clicks'] = get_clicks(page_graph, post_id)
    metrics["shares"] = get_shares(page_graph, post_id, start_date, end_date)
    return metrics
  end

  def get_posts(page_id, start_date, end_date)
    posts = []
    paginated_posts = get_paginated_posts(page_id)
    posts << paginated_posts
    loop do
      get_metrics(paginated_posts, page_id, start_date, end_date)
      paginated_posts = paginated_posts.next_page
      posts << paginated_posts
      break if paginated_posts == nil
    end
    return posts
  end

  def get_metrics(paginated_posts, page_id, start_date, end_date)
    paginated_posts.each do |fb_post|
      metrics = get_post_metrics(page_id, fb_post["id"], start_date, end_date) 
      message = Message.find_by_alternative_identifier(fb_post["id"])
      record_metrics(message, metrics, start_date)
    end
  end
  
  def record_metrics(message, metrics, impressions_date)
    if !message.nil?
      metrics["comments"].each do |comment|
        (message.comments << Comment.where(social_media_comment_id: comment["id"], comment_text: comment["message"], comment_date: comment["created_time"]).first_or_create) if !comment.nil?
      end
      #this is going to be a job in order to record the current impressions_date
      MetricsManager.update_impressions_by_day(impressions_date, message.social_network_id => metrics["impressions"])
      message.metrics << Metric.create(source: "facebook", data: { shares: metrics["shares"], likes: metrics["likes"], clicks: metrics["clicks"] })
      message.save
    end
  end
  
  def get_comments(post_id)
    comments = @graph.get_connections(post_id, "comments", period: 'day', filter: 'stream')
    return comments.nil? ? nil : comments
  end
  
  def get_impressions(page_id, post_id, start_date, end_date)
    impressions =  get_post_impressions(page_id, post_id, start_date, end_date)
    return impressions.nil? ? 0 : impressions
  end
  
  def get_likes(page_graph, post_id)
    likes = page_graph.get_connections(post_id, "likes", period: 'day', filter: 'stream')
    return likes.nil? ? nil : likes.count
  end
    
  def get_clicks(page_graph, post_id)
    clicks = page_graph.get_connections(post_id, "insights/post_consumptions_by_type", fields: 'values', period: 'day', filter: 'stream')
    return clicks[0]["values"][0]["value"]["other clicks"]
  end
  
  def get_shares(page_graph, post_id, start_date, end_date)
    shares = page_graph.get_connections(post_id, "sharedposts", since: start_date, until: end_date, filter: 'stream')
    return shares.first.nil? ? 0 : shares.first.count
  end
end