class FacebookAdsClient  
  def initialize
    secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
    Setting[:facebook_access_token] = secrets['facebook_access_token']
    # Setting[:facebook_app_secret] = secrets['facebook_app_secret']
    @session = FacebookAds::Session.new(access_token: Setting[:facebook_access_token])
  end
  
  def get_account(account)
    @account = FacebookAds::AdAccount.get(account, @session) 
    return @account
  end
  
  def get_campaign_names
    return @account.campaigns(fields: 'name, comments').map(&:name)
  end  

  def get_paginated_ads(ad_id)
    return @graph.get_connections(ad_id, 'ads')
  end
  
  def get_all_campaigns
    return @account.campaigns
  end
    
  def get_all_campaign_ids
    return @account.campaigns(fields: 'id').map(&:id)
  end
  
  def get_ad_sets
    campaigns = @account.campaigns
    @ad_sets = []
    campaigns.each do |campaign|
      @ad_sets << campaign.adsets
    end
    return @ad_sets
  end
     
  def get_ads
    ad_sets = @account.adsets
    @ads = []
    ad_sets.each do |ad_set|
      @ads << ad_set.ads
    end
    return @ads
  end
  
  def get_comments(object_id)
    @account.reload!
    
    # return @account.get(field: 'me', 'comments')
    campaign = @account.get(object_id: object_id)
    # p campaign
    return campaign
  end
  
  def get_paginated_ads
    return @graph.get_connections(ad_account: @account_id, fields: 'ads')
  end
  
  
  #   def get_ad_metrics(ad_id)
  #   post_comments = @graph.get_connections(post_id, "comments", filter: 'stream')
  #   loop do
  #     post_comments.each do |comment|
  #       make_comment = Comment.find_or_create_by(social_media_comment_id: comment["id"]) do |new_comment|
  #         new_comment.commentator_username = comment["from"]["name"],
  #         new_comment.commentator_id = comment["from"]["id"],  
  #         new_comment.comment_text = comment["message"]
  #       end
  #       make_comment.comment_date = make_comment["created_time"]
  #       make_comment.message = Message.find_by_published_text(published_text.squish)
        
  #       make_comment.save
  #     end
  #     post_comments = post_comments.next_page
  #     break if post_comments == nil
  #   end
  # end

  # def get_comments(page_id)
  #   paginated_posts = get_paginated_posts(page_id)
  #   loop do
  #     paginated_posts.each do |fb_post|
  #       get_post_comments(fb_post["id"], fb_post["message"]) 
  #     end
  #     paginated_posts = paginated_posts.next_page
  #     break if paginated_posts == nil
  #   end
  # end
end