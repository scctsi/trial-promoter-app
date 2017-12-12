require 'rails_helper'

RSpec.describe FacebookMetricsAggregator do
  before do
    secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
    allow(Setting).to receive(:[]).with(:facebook_access_token).and_return(secrets['facebook_access_token'])
    @facebook_metrics_aggregator = FacebookMetricsAggregator.new
    @message = create(:message, campaign_id: '6076520279839')
    
    VCR.use_cassette 'facebook_metrics_aggregator/test_setup' do
      pages = @facebook_metrics_aggregator.get_user_object
      @page = pages.select{ |page| page["name"] == "B Free of Tobacco" }[0]
    end
  end

  describe "(development only tests)", :development_only_tests => true do
    it 'gets the page B Free Of Tobacco' do
      expect(@page).not_to be_nil
      expect(@page["name"]).to eq("B Free of Tobacco")
    end
    
    it 'gets the impressions for an individual ad' do
      ad_id = '6073750722439'
      campaign_id = '6073750720839'
      ad_set = '6073750722239'
      VCR.use_cassette 'facebook_metrics_aggregator/get_ad_impressions' do
        impressions = @facebook_metrics_aggregator.get_ad_impressions(campaign_id)
  p impressions      
        expect(impressions).to eq(['something!!!!'])
      end
    end
    
    xit 'gets impressions for a page and matching them to the correct message via campaign id' do

      VCR.use_cassette 'facebook_metrics_aggregator/get_impressions' do
        @facebook_metrics_aggregator.get_impressions(@page["id"])
        
        expect(@message.comments.map(&:comment_text)).to include("how gross is that!!!!!")
      end
    end
  
    it 'gets the number of impressions seen of any content associated with the page B Free of Tobacco' do
      VCR.use_cassette 'facebook_metrics_aggregator/get_paginated_posts' do
        page_impressions = @facebook_metrics_aggregator.get_paginated_posts(@page["id"], "2017-04-20", "2017-04-21")

        expect(page_impressions.first["values"][0]["value"]).to eq(1352)
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