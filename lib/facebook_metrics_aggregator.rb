class FacebookMetricsAggregator
  def initialize
    secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
    Setting[:facebook_access_token] = secrets['facebook_access_token']
    @graph = Koala::Facebook::API.new(Setting[:facebook_access_token])
  end

  def get_user_object
    return @graph.get_connections("me", "accounts")
  end

  def get_paginated_posts(page_id)
    return @graph.get_connections(page_id, 'posts')
  end
  
  def get_post_impressions(post_id, published_text)
    # post_comments = @graph.get_connections(post_id, "comments", period: 'day', filter: 'stream')
    # post_likes = @graph.get_connections(post_id,"likes", period: 'day', filter: 'stream')
    post_impressions = @graph.get_connections(post_id, "ad_set")
    # page_impressions_paid = @graph.get_connections(post_id,"insights/page_impressions_paid", period: 'day', filter: 'stream')
    # post_shares = @graph.get_connections(post_id,"shares", period: 'day', filter: 'stream')
    p post_impressions
    loop do
      post_impressions.each do |impression|
        # metric_impression = Message.find_by_alternative_identifier(campaign_id: impression["id"]) do |new_impression|
        #   new_impression.impressionator_username = impression["from"]["name"],
        #   new_impression.impressionator_id = impression["from"]["id"],  
        #   new_impression.impression_text = impression["message"]
        # end
        # make_impression.impression_date = make_impression["created_time"]
        # make_impression.message = Message.find_by_published_text(published_text.squish)
        
        # make_impression.save
      end
      post_impressions = post_impressions.next_page
      break if post_impressions == nil
    end
  end

  def get_impressions(page_id)
    paginated_posts = get_paginated_posts(page_id)
    loop do
      paginated_posts.each do |fb_post|
        get_post_impressions(fb_post["id"], fb_post["message"]) 
      end
      paginated_posts = paginated_posts.next_page
      break if paginated_posts == nil
    end
  end
end