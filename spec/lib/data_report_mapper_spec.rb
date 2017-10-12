require 'rails_helper'
require 'google/apis/analytics_v3'

RSpec.describe DataReportMapper do
  before do
    @message = build(:message)
    # @message_null = build(:message)
    # @message.note = "Note"
    @message.scheduled_date_time =  ActiveSupport::TimeZone.new("America/Los_Angeles").local(2017, 4, 30, 12, 0, 0)
    @message.buffer_update = build(:buffer_update)
    # @message.buffer_update.sent_from_date_time = ActiveSupport::TimeZone.new("America/Los_Angeles").local(2017, 4, 30, 12, 1, 0)
    # @message.social_network_id = "870429890541228033"
    # @message.campaign_id = "202"
    visits_day_1 = build_list(:visit, 3, utm_content: @message.to_param, started_at: @message.scheduled_date_time + 1.hour)
    visits_day_2 = build_list(:visit, 2, utm_content: @message.to_param, started_at: @message.scheduled_date_time + 1.day + 1.hour)
    # build_list(:visit, 1, utm_content: @message.to_param, started_at: @message.scheduled_date_time + 2.day + 1.hour, ip: '128.125.77.139')
    # All visits on day one converted once each
    # visits_day_1.each do |visit|
    #   visit.ahoy_events << Ahoy::Event.new(visit_id: visit.id, name: "Converted")
    # end
    # One visit on day 2 converted many times
    # visits_day_2[0].ahoy_events << Ahoy::Event.new(visit_id: visits_day_2[0].id, name: "Converted")
    # visits_day_2[0].ahoy_events << Ahoy::Event.new(visit_id: visits_day_2[0].id, name: "Converted")

    # @message.metrics << Metric.new(source: :google_analytics, data: {'ga:sessions'=>2, 'ga:users'=>2, 'ga:exits' =>2, 'ga:sessionDuration' => 42, 'ga:timeOnPage' => 42, 'ga:pageviews' => 2})    
    # @message.website_session_count = 2
  end
  
  it 'builds an instance of a data_report_mapper for the experiment' do
    experiment = build(:experiment)
    data_report_mapper = DataReportMapper.new(experiment)
    
    expect(data_report_mapper.experiment).to eq(experiment)
  end

  it 'maps the message id to database_id' do
    expect(DataReportMapper.database_id(@message)).to eq(@message.id)
  end

  it 'maps the social_network_id to social_network_id' do
    expect(DataReportMapper.social_network_id(@message)).to eq("SNI: #{@message.social_network_id}")
  end

  it 'maps the campaign_id to campaign_id' do
    expect(DataReportMapper.campaign_id(@message)).to eq("CI: #{@message.campaign_id}")
  end
  
  it 'maps whether a message was backdated to backdated' do
    @message.backdated = nil
    
    expect(DataReportMapper.backdated(@message)).to eq("No")

    @message.backdated = false
    
    expect(DataReportMapper.backdated(@message)).to eq("No")
    
    @message.backdated = true
    
    expect(DataReportMapper.backdated(@message)).to eq("Yes")
  end

  it 'maps the message note to note' do
    expect(DataReportMapper.note(@message)).to eq(@message.note)
  end

  it 'maps the message note to note' do
    expect(DataReportMapper.note(@message)).to eq(@message.note)
  end
  
  describe 'experiment variables mapping methods' do
    it 'maps the message stem_id to stem' do 
      @message.message_template.experiment_variables['stem_id'] = 'FE51'
      expect(DataReportMapper.stem(@message)).to eq('FE51')
    end

    it 'maps the message fda_campaign to fda_campaign' do
        @message.message_template.experiment_variables['fda_campaign'] = 'FE'
        expect(DataReportMapper.fda_campaign(@message)).to eq('1')
        @message.message_template.experiment_variables['fda_campaign'] = 'TFL'
        expect(DataReportMapper.fda_campaign(@message)).to eq('2')
    end

    it 'maps the message theme to theme' do 
      themes = { 'health' => '1', 'appearace' => '2', 'money' => '3', 'love of family' => '4', 'addiction' => '5', 'health + community' => '6', 'health + family' => '7', 'UNCLEAR' => 'UNCLEAR' }
      themes.each do |theme, value|
        @message.message_template.experiment_variables['theme'] = theme
        expect(DataReportMapper.theme(@message)).to eq(value)
      end
      @message.message_template.experiment_variables['theme'] = 'UNCLEAR'
      expect(DataReportMapper.theme(@message)).to eq('UNCLEAR')
    end

    it 'maps the message experiment variable to lin_meth_factor' do
      (1..4).each do |lin_meth_factor|
        @message.message_template.experiment_variables['lin_meth_factor'] = lin_meth_factor.to_s
        expect(DataReportMapper.lin_meth_factor(@message)).to eq(lin_meth_factor.to_s)
      end
    end

    it 'maps the message experiment variable to lin_meth_level' do
      (1..11).each do |lin_meth_level|
        @message.message_template.experiment_variables['lin_meth_level'] = lin_meth_level.to_s
        expect(DataReportMapper.lin_meth_level(@message)).to eq(lin_meth_level.to_s)
      end
    end
  end

  it 'maps the message content to the variant' do
    @message.message_template.content = "Even if someone doesn't smoke, they could be breathing in the deadly mix by being around smokers.{url}"
    expect(DataReportMapper.variant(@message)).to eq("Even if someone doesn't smoke, they could be breathing in the deadly mix by being around smokers.")
  end

  it 'maps the scheduled date of the message to the day of the experiment' do
    # Message scheduled at noon 
    expect(DataReportMapper.day_experiment(@message)).to eq(12)
    # Message scheduled just before midnight
    @message.scheduled_date_time = ActiveSupport::TimeZone.new("America/Los_Angeles").local(2017,4,30,23,59,0)
    expect(DataReportMapper.day_experiment(@message)).to eq(12)
    # Message scheduled just after midnight of previous day
    @message.scheduled_date_time = ActiveSupport::TimeZone.new("America/Los_Angeles").local(2017,4,30,0,0,1)
    expect(DataReportMapper.day_experiment(@message)).to eq(12)
  end

  it 'uses the original_scheduled_date_time for calculating the day_experiment' do
    @message.medium = :ad
    @message.platform = :twitter
    @message.backdated = true
    @message.original_scheduled_date_time = ActiveSupport::TimeZone.new("America/Los_Angeles").local(2017, 5, 5, 12, 0, 0)
    
    expect(DataReportMapper.day_experiment(@message)).to eq(17)
  end
  
  it 'maps the date the message was published to the date sent' do
    expect(DataReportMapper.date_sent(@message)).to eq("2017-04-30")
    @message.buffer_update = nil
    expect(DataReportMapper.date_sent(@message)).to eq("2017-04-30")
    @message.medium = :ad
    expect(DataReportMapper.date_sent(@message)).to eq("2017-04-30")
  end

  it 'returns the original_scheduled_date_time for Twitter ads messages' do
    @message.medium = :ad
    @message.platform = :twitter
    @message.backdated = true
    @message.original_scheduled_date_time = ActiveSupport::TimeZone.new("America/Los_Angeles").local(2017, 5, 5, 12, 0, 0)
    
    expect(DataReportMapper.date_sent(@message)).to eq("2017-05-05")
  end

  it 'maps the day of the week the message was send to day_sent' do
    expect(DataReportMapper.day_sent(@message)).to eq('7')
    @message.scheduled_date_time = '29 April 2017 12:00:00'
    expect(DataReportMapper.day_sent(@message)).to eq('6')
    @message.scheduled_date_time = '28 April 2017 12:00:00'
    expect(DataReportMapper.day_sent(@message)).to eq('5')
    @message.scheduled_date_time = '27 April 2017 12:00:00'
    expect(DataReportMapper.day_sent(@message)).to eq('4')
    @message.scheduled_date_time = '26 April 2017 12:00:00'
    expect(DataReportMapper.day_sent(@message)).to eq('3')
    @message.scheduled_date_time = '25 April 2017 12:00:00'
    expect(DataReportMapper.day_sent(@message)).to eq('2')
    @message.scheduled_date_time = '24 April 2017 12:00:00'
    expect(DataReportMapper.day_sent(@message)).to eq('1')
  end

  it 'uses the original_scheduled_date_time when mapping the day of the week the message was send to day_sent' do
    @message.medium = :ad
    @message.platform = :twitter
    @message.backdated = true
    @message.original_scheduled_date_time = '4 April 2017 12:00:00'
    
    expect(DataReportMapper.day_sent(@message)).to eq('2')
  end

  it 'maps the time the message was sent to time sent' do
    @message.buffer_update.sent_from_date_time = '27 April 2017 12:00:02'
    expect(DataReportMapper.time_sent(@message)).to eq('12:00:02')
    @message.buffer_update.sent_from_date_time = nil
    expect(DataReportMapper.time_sent(@message)).to eq('NDA')
    @message.medium = :ad
    expect(DataReportMapper.time_sent(@message)).to eq('NDA')
  end

  it 'maps the social media platform to the sm_type' do
    @message.platform = :twitter
    expect(DataReportMapper.sm_type(@message)).to eq('T')
    @message.platform = :facebook
    expect(DataReportMapper.sm_type(@message)).to eq('F')
    @message.platform = :instagram 
    expect(DataReportMapper.sm_type(@message)).to eq('I')
  end

  it 'maps the message medium to the medium' do
    expect(DataReportMapper.medium(@message)).to eq('1')
    @message.medium = :ad
    expect(DataReportMapper.medium(@message)).to eq('2')
  end

  it 'maps image_present to the image' do
    expect(DataReportMapper.image_included(@message)).to eq('0')
    @message.image_present = 'with'
    expect(DataReportMapper.image_included(@message)).to eq('1')
  end

  describe 'clicks and click times' do
    before do
      @message.click_meter_tracking_link = build(:click_meter_tracking_link)
      #Day 1 starts on April 30th
      @message.click_meter_tracking_link.clicks << build_list(:click, 3, :spider => '0', :unique => '1', :click_time => DateTime.new(2017,4,30,12,23,13))    
      @message.click_meter_tracking_link.clicks << build_list(:click, 1, :spider => '0', :unique => '0', :click_time => DateTime.new(2017,4,30,01,23,13))
      @message.click_meter_tracking_link.clicks << build_list(:click, 1, :spider => '1', :unique => '0', :click_time => DateTime.new(2017,4,30,12,34,57))
      @message.click_meter_tracking_link.clicks << build_list(:click, 1, :spider => '1', :unique => '1', :click_time => DateTime.new(2017,4,30,11,34,57))
      #Day 2
      @message.click_meter_tracking_link.clicks << build_list(:click, 1, :spider => '1', :unique => '0', :click_time => DateTime.new(2017,5,1,12,34,57))
      @message.click_meter_tracking_link.clicks << build_list(:click, 1, :spider => '1', :unique => '1', :click_time => DateTime.new(2017,5,1,12,34,57))
      @message.click_meter_tracking_link.clicks << build_list(:click, 1, :spider => '0', :unique => '1', :click_time => DateTime.new(2017,5,1,13,44,56))
      @message.click_meter_tracking_link.clicks << build_list(:click, 1, :spider => '0', :unique => '0', :click_time => DateTime.new(2017,5,1,14,44,56))
      # This is actually day 3
      @message.click_meter_tracking_link.clicks << build_list(:click, 2, :spider => '0', :unique => '1', :click_time => DateTime.new(2017,5,1,19,26,1))
    end
    
    it 'maps the message total clicks for day 1 to total_clicks_day' do
      #TODO allows spiders and non-unique clicks
      expect(DataReportMapper.total_clicks_day(@message, 0).count).to eq(6)
    end
  
    it 'maps the message total clicks for day 2 to total_clicks_day' do
      #TODO allows spiders and non-unique clicks
      expect(DataReportMapper.total_clicks_day(@message, 1).count).to eq(4)
    end
  
    it 'maps the message total clicks for day 3 to total_clicks_day' do
      #TODO allows spiders and non-unique clicks
      expect(DataReportMapper.total_clicks_day(@message, 2).count).to eq(2)
    end
  
    it 'maps the message total human clicks for the entire experiment to total_clicks_experiment' do
      #TODO allows spiders and non-unique clicks
      expect(DataReportMapper.total_clicks_experiment(@message).count).to eq(12)
    end
  
    it 'maps the times of each kind of click (human, spider) per tracking link to click_time' do
      #TODO should get click times from clicks, e.g. self.clicks('human', true)
      clicks_day_1 = DataReportMapper.total_clicks_day(@message, 0)
      clicks_day_2 = DataReportMapper.total_clicks_day(@message, 1)
      clicks_day_3 = DataReportMapper.total_clicks_day(@message, 2)
      
      clicks_entire_experiment = DataReportMapper.total_clicks_experiment(@message)
      
      expect(DataReportMapper.click_time(clicks_entire_experiment, 'human', true)).to eq(["19:23:13", "19:23:13", "19:23:13", "20:44:56", "02:26:01", "02:26:01"])
      expect(DataReportMapper.click_time(clicks_entire_experiment)).to eq(["19:23:13", "19:23:13", "19:23:13", "20:44:56", "02:26:01", "02:26:01"])
      expect(DataReportMapper.click_time(clicks_entire_experiment, 'spider', false)).to eq(["19:34:57", "19:34:57"])
      expect(DataReportMapper.click_time(clicks_day_1, 'human', true)).to eq(["19:23:13", "19:23:13", "19:23:13"])
      expect(DataReportMapper.click_time(clicks_day_1, 'human', false)).to eq(["08:23:13"])
      expect(DataReportMapper.click_time(clicks_day_1, 'spider', true)).to eq(["18:34:57"])
      expect(DataReportMapper.click_time(clicks_day_1, 'spider', false)).to eq(["19:34:57"])
      expect(DataReportMapper.click_time(clicks_day_2, 'human', true)).to eq(["20:44:56"])
      expect(DataReportMapper.click_time(clicks_day_2, 'human', false)).to eq(["21:44:56"])
      expect(DataReportMapper.click_time(clicks_day_2, 'spider', true)).to eq(["19:34:57"])
      expect(DataReportMapper.click_time(clicks_day_2, 'spider', false)).to eq(["19:34:57"])
      expect(DataReportMapper.click_time(clicks_day_3, 'human', true)).to eq(["02:26:01", "02:26:01"])
      expect(DataReportMapper.click_time(clicks_day_3, 'human', false)).to eq([])
      expect(DataReportMapper.click_time(clicks_day_3, 'spider', true)).to eq([])
      expect(DataReportMapper.click_time(clicks_day_3, 'spider', false)).to eq([])
    end
  end

  describe 'impressions by day' do
    before do
      @message.impressions_by_day = { @message.scheduled_date_time.to_date => 100, (@message.scheduled_date_time + 1.day).to_date => 115, (@message.scheduled_date_time + 2.day).to_date => 120 }
      @message_twitter = build(:message, platform: :twitter)
      @message_twitter.metrics << Metric.new(source: :twitter, data: {"impressions"=>1394, "likes"=>0, "retweets"=>0, "replies"=>0, "clicks"=>4})
      @message_facebook = build(:message, platform: :facebook)
      @message_facebook.metrics << Metric.new(source: :facebook,  data: {"impressions"=>1259, "shares"=>0, "comments"=>0, "reactions"=>25})    
      @message_instagram= build(:message, platform: :instagram)
      @message_instagram.metrics << Metric.new(source: :facebook,  data: {"impressions"=>259, "shares"=>1, "comments"=>1, "reactions"=>15})
      @message.save 
      @message_twitter.save
      @message_facebook.save
      @message_instagram.save
    end
    
    describe 'for backdated Twitter ads' do
      before do
        @message.original_scheduled_date_time = @message.scheduled_date_time + 5.days
        @message.impressions_by_day = { @message.scheduled_date_time.to_date + 5.days => 100, (@message.scheduled_date_time + 6.days).to_date => 115, (@message.scheduled_date_time + 7.days).to_date => 120 }
        @message.medium = :ad
        @message.platform = :twitter
        @message.backdated = true
      end

      it 'maps the total impressions for day 1 to total_impressions_day (using impressions data 5 days from the scheduled_date_time)' do
        expect(DataReportMapper.total_impressions_day(@message, 0)).to eq(100)
      end
  
      it 'maps the total impressions to day 2 to total_impressions_day (using impressions data 6 days from the scheduled_date_time)' do
        expect(DataReportMapper.total_impressions_day(@message, 1)).to eq(115)
      end

      it 'maps the total impressions to day 3 to total_impressions_day (using impressions data 7 days from the scheduled_date_time)' do
        expect(DataReportMapper.total_impressions_day(@message, 2)).to eq(120)
      end
    end

    it 'maps the total impressions for day 1 to total_impressions_day' do
      expect(DataReportMapper.total_impressions_day(@message, 0)).to eq(100)
      @message.medium = :ad
      expect(DataReportMapper.total_impressions_day(@message, 0)).to eq(100)
    end

    it 'returns NDA for data that is missing' do
      @message.impressions_by_day = {}

      expect(DataReportMapper.total_impressions_day(@message, 0)).to eq('NDA')
      @message.medium = :ad
      expect(DataReportMapper.total_impressions_day(@message, 0)).to eq('NDA')
    end

    it 'maps the total impressions to day 2 to total_impressions_day_2' do
      expect(DataReportMapper.total_impressions_day(@message, 1)).to eq(15)
      @message.medium = :ad
      expect(DataReportMapper.total_impressions_day(@message, 1)).to eq(115)
    end
    
    it 'returns NDA for data that is missing on day 1 and displays impressions if data exists for day 2' do
      @message.impressions_by_day = { (@message.scheduled_date_time + 1.day).to_date => 0 }
      
      expect(DataReportMapper.total_impressions_day(@message, 0)).to eq('NDA')
      expect(DataReportMapper.total_impressions_day(@message, 1)).to eq(0)
      
      @message.medium = :ad
      expect(DataReportMapper.total_impressions_day(@message, 0)).to eq('NDA')
    end

    it 'returns NDA for data that is missing for either day 1 or day 2' do
      @message.impressions_by_day = {}
      expect(DataReportMapper.total_impressions_day(@message, 1)).to eq('NDA')
      @message.medium = :ad
      expect(DataReportMapper.total_impressions_day(@message, 1)).to eq('NDA')

      @message.impressions_by_day = {(@message.scheduled_date_time + 1.day).to_date => 1 }

      expect(DataReportMapper.total_impressions_day(@message, 1)).to eq(1)
      @message.medium = :ad
      expect(DataReportMapper.total_impressions_day(@message, 1)).to eq(1)
    end

    it 'maps the total impressions for day 3 to total_impressions_day' do
      @message.medium = :organic
      expect(DataReportMapper.total_impressions_day(@message, 2)).to eq(5)
      @message.medium = :ad
      expect(DataReportMapper.total_impressions_day(@message, 2)).to eq(120)
    end
    
    it 'displays impressions for day 3 even if data is missing for days 1 and/or 2' do
      @message.impressions_by_day = { (@message.scheduled_date_time + 2.day).to_date => 0 }
      
      expect(DataReportMapper.total_impressions_day(@message, 2)).to eq(0)
      
      @message.impressions_by_day = { (@message.scheduled_date_time + 1.day).to_date => 1, (@message.scheduled_date_time + 2.day).to_date => 1 }
      expect(DataReportMapper.total_impressions_day(@message, 2)).to eq(0)
      
      @message.medium = :ad
      @message.impressions_by_day = {}
      
      expect(DataReportMapper.total_impressions_day(@message, 2)).to eq('NDA')
    end

    it 'maps the total impressions for the duration of the experiment for each platform to total_impressions_experiment or return NDA' do
      expect(DataReportMapper.total_impressions_experiment(@message_twitter)).to eq(1394)
      expect(DataReportMapper.total_impressions_experiment(@message_facebook)).to eq(1259) 
      expect(DataReportMapper.total_impressions_experiment(@message_instagram)).to eq(259)
      
      @message.metrics = []
      
      expect(DataReportMapper.total_impressions_experiment(@message)).to eq("NDA") 
    end
  
    it 'returns 0 for organic, NDA for ad if data is missing for day 3' do
      @message.impressions_by_day = { (@message.scheduled_date_time).to_date => 0, (@message.scheduled_date_time + 1.day).to_date => 0, (@message.scheduled_date_time + 2.day).to_date => 0 }
      expect(DataReportMapper.total_impressions_day(@message, 2)).to eq(0) 
      @message.impressions_by_day = {}
      @message.medium = :ad
      expect(DataReportMapper.total_impressions_day(@message, 2)).to eq('NDA')

      @message.medium = :organic
      @message.impressions_by_day = { (@message.scheduled_date_time).to_date => 0, (@message.scheduled_date_time + 1.day).to_date => 0, (@message.scheduled_date_time + 2.day).to_date => 1 }

      expect(DataReportMapper.total_impressions_day(@message, 2)).to eq(1)
      @message.medium = :ad
      expect(DataReportMapper.total_impressions_day(@message, 2)).to eq(1)
    end
  end

  describe 'twitter metrics' do
    before do
      @message.metrics << Metric.new(source: :twitter, data: { 'retweets' => 12 , 'replies'=> 3, 'likes'=> 14 })
      @message.save
    end

    it 'maps the number of twitter shares to retweets_twitter' do
      expect(DataReportMapper.retweets_twitter(@message)).to eq(12)
    end

    it 'maps the number of twitter likes to likes_twitter' do
      expect(DataReportMapper.likes_twitter(@message)).to eq(14)
    end

    it 'maps the number of twitter replies to replies_twitter' do
      expect(DataReportMapper.replies_twitter(@message)).to eq(3)
    end

    # it 'returns NDA for retweets_twitter if data is not available' do
    #   @message.metrics[1].data = { 'replies'=> 3, 'likes'=> 14 }
    #   expect(DataReportMapper.retweets_twitter(@message)).to eq('NDA')
    # end

    # it 'returns NDA for likes_twitter if data is not available' do
    #   @message.metrics[1].data = { 'retweets' => 12 , 'replies'=> 3 }
    #   expect(DataReportMapper.likes_twitter(@message)).to eq('NDA')
    # end

    # it 'returns replies_twitter if data is not available' do
    #   @message.metrics[1].data = { 'retweets' => 12, 'likes'=> 14 }
    #   expect(DataReportMapper.replies_twitter(@message)).to eq('NDA')
    # end
  end

  # describe 'facebook metrics' do
  #   before do
  #     @message.platform = :facebook
  #     @message.metrics << Metric.new(source: :facebook, data: {'shares' => 1 , 'comments' => 4, 'reactions' => 14 })
  #     @message.save
  #   end

  #   it 'maps the number of facebook shares to shares_facebook' do
  #     expect(DataReportMapper.shares_facebook(@message)).to eq(1)
  #     expect(DataReportMapper.shares_instagram(@message)).to eq("N/A")
  #     expect(DataReportMapper.retweets_twitter(@message)).to eq("N/A")
  #   end

  #   it 'maps the number of facebook reactions to reactions_facebook' do
  #     expect(DataReportMapper.reactions_facebook(@message)).to eq(14)
  #     expect(DataReportMapper.reactions_instagram(@message)).to eq("N/A")
  #     expect(DataReportMapper.likes_twitter(@message)).to eq("N/A")
  #   end

  #   it 'maps the number of facebook comments to comments_facebook' do
  #     expect(DataReportMapper.comments_facebook(@message)).to eq(4)
  #     expect(DataReportMapper.comments_instagram(@message)).to eq("N/A")
  #     expect(DataReportMapper.replies_twitter(@message)).to eq("N/A")
  #   end
    
  #   it 'maps the number of facebook likes to reactions_facebook' do
  #     @message.metrics << Metric.new(source: :facebook, data: {'shares' => 0 , 'comments' => 0, 'likes' => 1 })
  #     expect(DataReportMapper.reactions_facebook(@message)).to eq(1) 
  #   end

  #   it 'returns NDA for shares_facebook if data is not available' do
  #     @message.metrics[1].data = {'comments' => 0, 'likes' => 1 }
  #     expect(DataReportMapper.shares_facebook(@message)).to eq('NDA')
  #   end

  #   it 'returns NDA for reactions_facebook if data is not available' do
  #     @message.metrics[1].data = {'shares' => 1, 'comments' => 4}
  #     expect(DataReportMapper.reactions_facebook(@message)).to eq('NDA')
  #   end

  #   it 'returns NDA for comments_facebook if data is not available' do
  #     @message.metrics[1].data = {'shares' => 1, 'likes' => 14}
  #     expect(DataReportMapper.comments_facebook(@message)).to eq('NDA')
  #   end
  # end

  # describe 'instagram metrics' do
  #   before do
  #     @message.platform = :instagram
  #     @message.metrics << Metric.new(source: :facebook, data: { 'shares' => 0 , 'comments' => 1, 'reactions' => 24 })
  #     @message.save
  #   end

  #   it 'maps the number of instagram shares to shares_instagram' do
  #     expect(DataReportMapper.shares_instagram(@message)).to eq(0)
  #     expect(DataReportMapper.shares_facebook(@message)).to eq("N/A")
  #     expect(DataReportMapper.retweets_twitter(@message)).to eq("N/A")
  #   end

  #   it 'maps the number of instagram comments to comments_instagram' do
  #     expect(DataReportMapper.comments_instagram(@message)).to eq(1)
  #     expect(DataReportMapper.comments_facebook(@message)).to eq("N/A")
  #     expect(DataReportMapper.replies_twitter(@message)).to eq("N/A")
  #   end

  #   it 'maps the number of instagram reactions to reactions_instagram' do
  #     expect(DataReportMapper.reactions_instagram(@message)).to eq(24)
  #     expect(DataReportMapper.reactions_facebook(@message)).to eq("N/A")
  #     expect(DataReportMapper.likes_twitter(@message)).to eq("N/A")
  #   end
    
  #   it 'returns the number of instagram likes to reactions_instagram' do
  #     @message.metrics << Metric.new(source: :facebook, data: {'shares' => 0 , 'comments'=> 0, 'likes'=> 1 })
  #     expect(DataReportMapper.reactions_instagram(@message)).to eq(1) 
  #   end

  #   it 'returns NDA for shares_instagram if data is not available' do
  #     @message.metrics[1].data = { 'comments' => 1, 'reactions' => 24 }
  #     expect(DataReportMapper.shares_instagram(@message)).to eq('NDA')
  #   end

  #   it 'returns NDA for comments_instagram if data is not available' do
  #     @message.metrics[1].data = { 'shares' => 0 , 'reactions' => 24 }
  #     expect(DataReportMapper.comments_instagram(@message)).to eq('NDA')
  #   end

  #   it 'returns NDA for reactions_instagram if data is not available' do
  #     @message.metrics[1].data = { 'shares' => 0 , 'comments' => 1 }
  #     expect(DataReportMapper.reactions_instagram(@message)).to eq('NDA')
  #   end
  # end

  # it 'maps the number of sessions on day 1 to total_sessions_day_1' do
  #   expect(DataReportMapper.total_sessions_day_1(@message)).to eq(3)
  # end

  # it 'maps the number of sessions on day 2 to total_sessions_day_2' do
  #   expect(DataReportMapper.total_sessions_day_2(@message)).to eq(2)
  # end

  # it 'maps the number of sessions on day 3 to total_sessions_day_3' do
  #   build_list(:visit, 1, utm_content: @message.to_param, started_at: @message.scheduled_date_time + 2.day + 1.hour)
  #   expect(DataReportMapper.total_sessions_day_3(@message)).to eq(1)
  # end

  # it 'ignores the IP address from the list of TCORS addresses' do
  #   expect(DataReportMapper.total_sessions_day_3(@message)).to eq(0)
  # end

  # it 'maps the number of sessions for the whole experiment to total_sessions_experiment' do
  #   expect(DataReportMapper.total_sessions_experiment(@message)).to eq(5)
  # end

  # it 'maps the number of conversions for day 1 to each website link to total_goals_day1' do  
  #   expect(DataReportMapper.total_website_clicks_day_1(@message)).to eq(3)
  # end

  # it 'maps the number of conversions for day 2 to each website link to total_goals_day2' do 
  #   expect(DataReportMapper.total_website_clicks_day_2(@message)).to eq(1)
  # end

  # it 'maps the number of conversions for day 3 to each website link to total_goals_day3' do  
  #   expect(DataReportMapper.total_website_clicks_day_3(@message)).to eq(0)
  # end

  # it 'maps the number of conversions for the duration of the experiment to total_goals_experiment' do 
  #   expect(DataReportMapper.total_website_clicks_experiment(@message)).to eq(4)
  # end

  # it 'maps the number of users for each website to users' do
  #   expect(DataReportMapper.users(@message)).to eq(2)
  #   expect(DataReportMapper.users(@message_null)).to eq('NDA') 
  # end

  # it 'maps the number of website exits for each website to exits' do
  #   expect(DataReportMapper.exits(@message)).to eq(2)
  #   expect(DataReportMapper.exits(@message_null)).to eq('NDA') 
  # end

  # it 'maps the duration of the user sessions for each website to session_duration' do
  #   expect(DataReportMapper.session_duration(@message)).to eq(42)
  #   expect(DataReportMapper.session_duration(@message_null)).to eq('NDA') 
  # end

  # it 'maps the time on each webpage for each website to time_onpage' do
  #   expect(DataReportMapper.time_on_page(@message)).to eq(42)  
  #   expect(DataReportMapper.time_on_page(@message_null)).to eq('NDA') 
  # end

  # it 'maps the number of page views for each website to pageviews' do
  #   expect(DataReportMapper.pageviews(@message)).to eq(2)
  #   expect(DataReportMapper.pageviews(@message_null)).to eq('NDA') 
  # end
end
