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

  def get_page_token(page_id)
    page_token = @graph.get_page_access_token(page_id)
    return Koala::Facebook::API.new(page_token)
  end

  def get_ad_impressions(ad_id)
    ad_impressions = @graph.get_connections(ad_id, "insights/action_report_time", since: "2017-04-20", until: "2017-07-13")

    return ad_impressions
  end
  
  
  def get_paginated_posts(page_id, start_date = "2017-04-19", end_date = "2017-07-13")
    page_graph = get_page_token(page_id)
    return page_graph.get_connections(page_id, 'posts', since: start_date, until: end_date)
  end
  
  def get_post_impressions(page_id, post_id, start_date = "2017-04-19", end_date = "2017-07-13")
    impressions = {}
    page_graph = get_page_token(page_id)

    comments = @graph.get_connections(post_id, "comments", period: 'day', filter: 'stream')
    impressions['comments'] = !comments.nil? ? comments : nil
    
    likes = page_graph.get_connections(post_id, "likes", period: 'day', filter: 'stream')
    impressions['likes'] = !likes.nil? ? likes.count : nil
    
    shares = page_graph.get_connections(post_id, "sharedposts", since: "2017-04-19", until: "2017-07-13", filter: 'stream')
    impressions["shares"] = shares.first if !shares.first.nil?
    
    return impressions
  end

  def get_posts(page_id)
    # page_token = @graph.get_page_access_token(page_id)
    
    @posts = []
    paginated_posts = get_paginated_posts(page_id)
    @posts << paginated_posts
    loop do
      paginated_posts.each do |fb_post|
        impressions = get_post_impressions(page_id, fb_post["id"]) 
        message = Message.find_by_alternative_identifier(fb_post["id"])

        if !message.nil?
          impressions["comments"].each do |comment|
            (message.comments << Comment.create(comment_text: comment["message"], social_media_comment_id: comment["id"])) if !comment.nil?
          end
          message.metrics << Metric.create(source: "facebook", data: { shares: impressions["shares"], likes: impressions["likes"] })
          message.save
        end
      end
      paginated_posts = paginated_posts.next_page
      @posts << paginated_posts
      break if paginated_posts == nil
    end
    return @posts
  end
end