class FacebookMetricsAggregator
  def initialize
    secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
    Setting[:facebook_access_token] = secrets['facebook_access_token']
    Koala.config.api_version = "v2.11"
    @graph = Koala::Facebook::API.new(Setting[:facebook_access_token])
    # @ad_session = FacebookAds::Session.new(access_token: Setting[:facebook_access_token])
  end
  
  # def get_ad_account(account_number, name)
  #   ad_account =  FacebookAds::AdAccount.get(account_number, name, @ad_session)
  #   p ad_account
  #   return ad_account
  # end

  def get_user_object
    return @graph.get_connections("me", "accounts")
  end

  def get_ads(account, name)
    return FacebookAds::AdAccount.get(account, name, @ad_session)
  end




  def get_ad_impressions(ad_id)
    ad_impressions = @graph.get_connections(ad_id, "insights/action_report_time", since: "2017-04-20", until: "2017-07-13")
    return ad_impressions
  end
  
  
  
  
  
  
  
  
  def get_paginated_posts(page_id, start_date = "2017-04-19", end_date = "2017-07-13")
    page_token = @graph.get_page_access_token(page_id)
    @page_graph = Koala::Facebook::API.new(page_token)
    return @page_graph.get_connections(page_id, 'posts', since: start_date, until: end_date)
  end
  
  def get_post_impressions(page_graph, post_id, start_date = "2017-04-19", end_date = "2017-07-13")
    # post_comments = @graph.get_connections(post_id, "comments", period: 'day', filter: 'stream')
    # post_likes = @graph.get_connections(post_id,"likes", period: 'day', filter: 'stream')
    # post_likes = @graph.get_connections(post_id, "reactions", filter: 'stream')
    # p @graph.get_object(post_id)
    # post_insights = @graph.get_connections(post_id, "likes", since: "2017-04-19", until: "2017-07-13", filter: 'stream')

    # @graph.get_connection(post_id, "likes")
    
p @graph.get_objects(post_id, :fields => "likes.summary(true)")


  end

  def get_posts(page_id)
    page_token = @graph.get_page_access_token(page_id)
    @posts = []
    page_graph = Koala::Facebook::API.new(page_token)
    paginated_posts = get_paginated_posts(page_id)
    @posts << paginated_posts
    loop do
      paginated_posts.each do |fb_post|
        get_post_impressions(page_graph, fb_post["id"]) 
      end
      paginated_posts = paginated_posts.next_page
      @posts << paginated_posts
      break if paginated_posts == nil
    end
    return @posts
  end
end