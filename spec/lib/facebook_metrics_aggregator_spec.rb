require 'rails_helper'

RSpec.describe FacebookMetricsAggregator do
  before do
    secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
    allow(Setting).to receive(:[]).with(:facebook_access_token).and_return(secrets['facebook_access_token'])
    @facebook_metrics_aggregator = FacebookMetricsAggregator.new
    @messages = create_list(:message, 3)
    @messages[0].social_network_id = "980601328736431_1061544820642081"
    @messages[1].social_network_id = "980601328736431_1009727572490473"
    @messages[2].social_network_id = "1009727572490473_1010968539033043"
    @messages.each{|message| message.save}
    
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
    
    it 'gets the impressions for an individual post' do
      post_ids = ["980601328736431_1009727572490473", "980601328736431_1056074954522401", "980601328736431_1060154484114448"]

      VCR.use_cassette 'facebook_metrics_aggregator/get_post_impressions' do
        impressions = []
        
        post_ids.each do |post_id|
          impressions << @facebook_metrics_aggregator.get_post_impressions(@page["id"], post_id)
        end
        
        expect(impressions[0]["likes"]).to eq(19)
        expect(impressions[0]["comments"].count).to eq(1)
        expect(impressions[0]["shares"]).to eq(nil)
        expect(impressions[1]["likes"]).to eq(25)
        expect(impressions[1]["comments"].count).to eq(24)
        expect(impressions[1]["shares"].count).to eq(3)
        expect(impressions[2]["likes"]).to eq(25)
        expect(impressions[2]["comments"].count).to eq(3)
        expect(impressions[2]["shares"]).to eq(nil)
      end
    end
    
    it 'gets posts for the page B Free of Tobacco' do
      VCR.use_cassette 'facebook_metrics_aggregator/get_posts' do
        posts = @facebook_metrics_aggregator.get_posts(@page["id"])

        expect(posts[0][0]["message"]).to eq("#Smoking can weaken your immune system, leaving you more vulnerable to bronchitis & pneumonia. http://bit.ly/2sHRInS")
        expect(posts[0][0]["id"]).to eq("980601328736431_1061544820642081")
      end
    end
  
    it 'gets the posts for the page B Free of Tobacco' do
      VCR.use_cassette 'facebook_metrics_aggregator/get_paginated_posts' do

        posts = @facebook_metrics_aggregator.get_paginated_posts(@page["id"], "2017-04-20", "2017-04-21")

        expect(posts.first["message"]).to eq( "Even occasional #smoking can hurt you. On average, every cig reduces your life by 11 minutes. http://bit.ly/2oq3WdA")
        expect(posts.first["id"]).to eq("980601328736431_1008353069294590")
      end
    end
    
    it 'does not add repeat comments' do
      VCR.use_cassette 'facebook_metrics_aggregator/get_double_post_comments' do
        posts = @facebook_metrics_aggregator.get_paginated_posts(@page["id"])

        expect(posts.count).to eq(25)
      end
    end
  end
end