class FacebookMetricsAggregator
  def initialize
    secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
    Setting[:facebook_access_token] = secrets['facebook_access_token']
    Koala.config.api_version = "v2.10"
    @graph = Koala::Facebook::API.new(Setting[:facebook_access_token])
    @ad_session = FacebookAds::Session.new(access_token: Setting[:facebook_access_token])
  end
  
  def get_ad_account(account, name)
    @ad_account = FacebookAds::AdAccount.get(account, name, @ad_session)
  end

  def get_user_object
    return @graph.get_connections("me", "accounts")
  end

  def get_ad_impressions(ad_id)
    ad_impressions = @graph.get_connections(ad_id, "action_report_time", since: "2017-04-20", until: "2017-07-13")
    return ad_impressions
  end
  
  
  
  
  
  
  
  
  def get_paginated_posts(page_id, start_date, end_date)
    return @graph.get_connections(page_id, 'insights/page_impressions', since: start_date, until: end_date)
  end
  
  def get_post_impressions(post_id, published_text, start_date = "2017-04-19", end_date = "2017-07-13")
    # post_comments = @graph.get_connections(post_id, "comments", period: 'day', filter: 'stream')
    # post_likes = @graph.get_connections(post_id,"likes", period: 'day', filter: 'stream')
    # post_impressions = @graph.get_connections(post_id, 'likes', since: "2017-05-17", until: "2017-05-18")
    page_impressions_paid = @graph.get_connections(post_id,"insights/page_impressions_paid", since: start_date, until: end_date)
    # post_shares = @graph.get_connections(post_id,"shares", period: 'day', filter: 'stream')

    loop do
      page_impressions_paid.each do |impression|
        message = Message.find_by_alternative_identifier(campaign_id: impression["id"]) 


      end
      page_impressions_paid = page_impressions_paid.next_page
      break if page_impressions_paid == nil
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