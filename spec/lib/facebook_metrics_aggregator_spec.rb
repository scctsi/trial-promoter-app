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
    
    it 'gets the lifetime impressions for a single post' do
      post_id = "980601328736431_1009727572490473"

      VCR.use_cassette 'facebook_metrics_aggregator/get_post_impressions' do
        
        impressions = @facebook_metrics_aggregator.get_post_impressions(@page["id"], post_id, Date.new(2017, 4, 19), Date.new(2017, 7, 13))
      
        expect(impressions).to eq(502)
      end
    end
    
    it 'gets the impressions for an individual post' do
      post_ids = ["980601328736431_1009727572490473", "980601328736431_1056074954522401", "980601328736431_1060154484114448"]

      VCR.use_cassette 'facebook_metrics_aggregator/get_post_metrics' do
        metrics = []
        
        post_ids.each do |post_id|
          metrics << @facebook_metrics_aggregator.get_post_metrics(@page["id"], post_id, Date.new(2017, 4, 19), Date.new(2017, 7, 13))
        end
        expect(metrics[0]["likes"]).to eq(19)
        expect(metrics[0]["comments"].count).to eq(1)
        expect(metrics[0]["clicks"]).to eq(3)
        expect(metrics[0]["shares"]).to eq(0)
        expect(metrics[1]["likes"]).to eq(25)
        expect(metrics[1]["comments"].count).to eq(24)
        expect(metrics[1]["clicks"]).to eq(90)
        expect(metrics[1]["shares"]).to eq(3)
        expect(metrics[2]["likes"]).to eq(25)
        expect(metrics[2]["comments"].count).to eq(3)
        expect(metrics[2]["clicks"]).to eq(10)
        expect(metrics[2]["shares"]).to eq(0)
      end
    end
    
    it 'gets posts for the page B Free of Tobacco on a specific day' do
      VCR.use_cassette 'facebook_metrics_aggregator/get_posts' do
        posts_day = @facebook_metrics_aggregator.get_posts(@page["id"], Date.new(2017, 4, 19), Date.new(2017, 7, 13))

        @messages.each{|m| m.reload }
        
        expect(@messages[0].metrics[0]["data"]).to include(:shares=>0, :likes=>25)
        expect(@messages[1].metrics[0]["data"]).to include(:shares=>0, :likes=>19)
        expect(@messages[2].metrics[0]).to be(nil)
        expect(@messages[0].impressions_by_day).to eq({ Date.new(2017, 4, 19) => 1514 })
        expect(@messages[1].impressions_by_day).to eq({ Date.new(2017, 4, 19) => 502 })
        expect(@messages[2].impressions_by_day).to eq({})
        expect(posts_day.count).to eq(12)
        expect(posts_day[0][0]["message"]).to eq("#Smoking can weaken your immune system, leaving you more vulnerable to bronchitis & pneumonia. http://bit.ly/2sHRInS")
        expect(posts_day[1][0]["message"]).to eq("About 30% of US cancer deaths are linked to #smoking. Smoking can cause cancer almost anywhere in the body. http://bit.ly/2tlJhxv")
        expect(posts_day[0][0]["id"]).to eq("980601328736431_1061544820642081")
        expect(posts_day[1][0]["id"]).to eq("980601328736431_1055617114568185")
      end
    end
  
    it 'gets the posts for the page B Free of Tobacco' do
      VCR.use_cassette 'facebook_metrics_aggregator/get_paginated_posts' do

        posts = @facebook_metrics_aggregator.get_paginated_posts(@page["id"], Date.new(2017, 4, 20), Date.new(2017, 4, 21))

        expect(posts.count).to eq(3)
        expect(posts.first["message"]).to eq( "Even occasional #smoking can hurt you. On average, every cig reduces your life by 11 minutes. http://bit.ly/2oq3WdA")
        expect(posts.first["id"]).to eq("980601328736431_1008353069294590")
      end
    end
    
    it 'does not add repeat comments' do
      VCR.use_cassette 'facebook_metrics_aggregator/get_double_post_comments' do
        paginated_posts = @facebook_metrics_aggregator.get_paginated_posts(@page["id"])

        expect(paginated_posts.count).to eq(25)
      end
    end
  end
end