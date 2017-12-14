require 'rails_helper'

RSpec.describe FacebookMetricsAggregator do
  before do
    secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
    allow(Setting).to receive(:[]).with(:facebook_access_token).and_return(secrets['facebook_access_token'])
    @facebook_metrics_aggregator = FacebookMetricsAggregator.new
    
    VCR.use_cassette 'facebook_metrics_aggregator/test_setup' do
      pages = @facebook_metrics_aggregator.get_user_object
      @page = pages.select{ |page| page["name"] == "Be Free of Tobacco" }[0]
    end
  end

  describe "(development only tests)", :development_only_tests => true do
    it 'gets the page Be Free Of Tobacco' do
      expect(@page).not_to be_nil
      expect(@page["name"]).to eq("Be Free of Tobacco")
    end
    
    xit 'gets the ad account B Free Of Tobacco' do
      VCR.use_cassette 'facebook_metrics_aggregator/get_ad_account' do
        ad_account = @facebook_metrics_aggregator.get_ad_account(@page["id"], @page["name"])
        
        expect(ad_account).not_to be_nil
        expect(ad_account["id"]).to eq("980601328736431")
        # expect(ad_account["name"]).to eq("B Free of Tobacco")
      end
    end
    
    xit 'gets the ads associated with B Free of Tobacco' do
      VCR.use_cassette 'facebook_metrics_aggregator/get_ads' do
        ads = @facebook_metrics_aggregator.get_ads(@page["id"], @page["name"])
      end
    end
    
    it 'gets the impressions for an individual post' do
      post_id = "1462412660449136_1544711788885889"
      
      VCR.use_cassette 'facebook_metrics_aggregator/get_post_impressions' do
        impressions = @facebook_metrics_aggregator.get_post_impressions(@page, post_id)
        
        expect(impressions).to eq([])
      end
    end
    
    xit 'gets posts for the page B Free of Tobacco' do
      VCR.use_cassette 'facebook_metrics_aggregator/get_posts' do
        posts = @facebook_metrics_aggregator.get_posts(@page["id"])

        expect(posts[0][0]["message"]).to eq("#Smoking can weaken your immune system, leaving you more vulnerable to bronchitis & pneumonia. http://bit.ly/2sO9dhf")
        expect(posts[0][0]["id"]).to eq("1462412660449136_1597503696940031")
      end
    end
  
    xit 'gets the posts for the page B Free of Tobacco' do
      VCR.use_cassette 'facebook_metrics_aggregator/get_paginated_posts' do

        posts = @facebook_metrics_aggregator.get_paginated_posts(@page["id"], "2017-04-20", "2017-04-21")

        expect(posts.first["message"]).to eq("Even occasional #smoking can hurt you. On average, every cig reduces your life by 11 minutes. http://bit.ly/2pxAUxc")
        expect(posts.first["id"]).to eq("1462412660449136_1510252278998507")
      end
    end
    
    xit 'gets comments for an individual post' do
      VCR.use_cassette 'facebook_metrics_aggregator/get_post_comments' do
        posts = @facebook_metrics_aggregator.get_paginated_posts(@page["id"])
        @facebook_metrics_aggregator.get_post_comments(posts[5]["id"], posts[5]["message"])
        
        expect(Comment.count).to eq(3)
      end
    end
    
    xit 'does not add repeat comments' do
      VCR.use_cassette 'facebook_metrics_aggregator/get_double_post_comments' do
        posts = @facebook_metrics_aggregator.get_paginated_posts(@page["id"])
        @facebook_metrics_aggregator.get_post_comments(posts[5]["id"], posts[5]["message"])
        @facebook_metrics_aggregator.get_post_comments(posts[5]["id"], posts[5]["message"])
        
        expect(Comment.count).to eq(3)
      end
    end
  end
end