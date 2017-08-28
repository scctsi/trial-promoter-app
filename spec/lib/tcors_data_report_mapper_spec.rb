require 'rails_helper'
require 'google/apis/analytics_v3'

RSpec.describe TcorsDataReportMapper do
  before do
    @message = create(:message)
    @message.scheduled_date_time =  ActiveSupport::TimeZone.new("America/Los_Angeles").local(2017,4,30,12,0,0)
    @message.buffer_update = create(:buffer_update)
    @message.buffer_update.sent_from_date_time = ActiveSupport::TimeZone.new("America/Los_Angeles").local(2017,4,30,12,1,0)
    visits_1 = create_list(:visit, 3, utm_content: @message.to_param, started_at: @message.scheduled_date_time + 1.hour)
    create_list(:visit, 2, utm_content: @message.to_param, started_at: @message.scheduled_date_time + 1.day + 1.hour)
    create_list(:visit, 1, utm_content: @message.to_param, started_at: @message.scheduled_date_time + 2.day + 1.hour, ip: '128.125.77.139')
    visits_1.each do |visit|
      visit.ahoy_events << Ahoy::Event.new(visit_id: visit.id)
    end
    @message.click_meter_tracking_link = create(:click_meter_tracking_link)
    @message.click_meter_tracking_link.clicks << create_list(:click, 3, :spider => '0', :unique => '1', :click_time => ActiveSupport::TimeZone.new("America/Los_Angeles").local(2017,4,30,12,23,13))
    @message.click_meter_tracking_link.clicks << create_list(:click, 1, :spider => '1', :click_time => ActiveSupport::TimeZone.new("America/Los_Angeles").local(2017,5,1,12,34,57))
    @message.click_meter_tracking_link.clicks << create_list(:click, 1, :spider => '0', :unique => '1', :click_time => ActiveSupport::TimeZone.new("America/Los_Angeles").local(2017,5,1,13,44,56))
    @message.click_meter_tracking_link.clicks << create_list(:click, 2, :spider => '0', :unique => '1', :click_time => ActiveSupport::TimeZone.new("America/Los_Angeles").local(2017,5,2,19,26,1))
    @message.metrics << Metric.new(source: :google_analytics, data: {'ga:sessions'=>2, 'ga:users'=>2, 'ga:exits' =>2, 'ga:sessionDuration' => 42, 'ga:timeOnPage' => 42, 'ga:pageviews' => 2})
    @message.website_session_count = 2
    @message.save
  end

  describe 'experiment variables mapping methods' do
    it 'maps the message id to database_id' do
      expect(TcorsDataReportMapper.database_id(@message)).to eq(@message.id)
    end
    
    it 'maps the message stem_id to stem' do
      @message.message_template.experiment_variables['stem_id'] = 'FE51'
      expect(TcorsDataReportMapper.stem(@message)).to eq('FE51')
    end

    it 'maps the message fda_campaign to fda_campaign' do
      (1..2).each do |fda_campaign|
        @message.message_template.experiment_variables['fda_campaign'] = fda_campaign.to_s
        expect(TcorsDataReportMapper.fda_campaign(@message)).to eq(fda_campaign.to_s)
      end
    end

    it 'maps the message theme to theme' do 
      (1..7).each do |theme|
        @message.message_template.experiment_variables['theme'] = theme.to_s
        expect(TcorsDataReportMapper.theme(@message)).to eq(theme.to_s)
      end
    end

    it 'maps the message experiment variable to lin_meth_factor' do
      (1..4).each do |lin_meth_factor|
        @message.message_template.experiment_variables['lin_meth_factor'] = lin_meth_factor.to_s
        expect(TcorsDataReportMapper.lin_meth_factor(@message)).to eq(lin_meth_factor.to_s)
      end
    end

    it 'maps the message experiment variable to lin_meth_level' do
      (1..11).each do |lin_meth_level|
        @message.message_template.experiment_variables['lin_meth_level'] = lin_meth_level.to_s
        expect(TcorsDataReportMapper.lin_meth_level(@message)).to eq(lin_meth_level.to_s)
      end
    end
  end

  it 'maps the message content to the variant' do
    expect(TcorsDataReportMapper.variant(@message)).to eq('Content')
  end

  it 'maps the scheduled date of the message to the day of the experiment' do
    # Message scheduled at noon
    expect(TcorsDataReportMapper.day_experiment(@message)).to eq(12)
    # Message scheduled just before midnight
    @message.scheduled_date_time = ActiveSupport::TimeZone.new("America/Los_Angeles").local(2017,4,30,23,59,0)
    expect(TcorsDataReportMapper.day_experiment(@message)).to eq(12)
    # Message scheduled just after midnight of previous day
    @message.scheduled_date_time = ActiveSupport::TimeZone.new("America/Los_Angeles").local(2017,4,30,0,0,1)
    expect(TcorsDataReportMapper.day_experiment(@message)).to eq(12)
  end

  it 'maps the date the message was published to the date sent' do
    expect(TcorsDataReportMapper.date_sent(@message)).to eq("2017-04-30")
    @message.buffer_update = nil
    expect(TcorsDataReportMapper.date_sent(@message)).to eq("2017-04-30")
    @message.medium = :ad
    expect(TcorsDataReportMapper.date_sent(@message)).to eq("N/A")
  end

  it 'maps the date the message was published to the day of the week' do
    expect(TcorsDataReportMapper.day_sent(@message)).to eq('7')
    @message.scheduled_date_time = '29 April 2017 12:00:00'
    expect(TcorsDataReportMapper.day_sent(@message)).to eq('6')
    @message.scheduled_date_time = '28 April 2017 12:00:00'
    expect(TcorsDataReportMapper.day_sent(@message)).to eq('5')
    @message.scheduled_date_time = '27 April 2017 12:00:00'
    expect(TcorsDataReportMapper.day_sent(@message)).to eq('4')
    @message.scheduled_date_time = '26 April 2017 12:00:00'
    expect(TcorsDataReportMapper.day_sent(@message)).to eq('3')
    @message.scheduled_date_time = '25 April 2017 12:00:00'
    expect(TcorsDataReportMapper.day_sent(@message)).to eq('2')
    @message.scheduled_date_time = '24 April 2017 12:00:00'
    expect(TcorsDataReportMapper.day_sent(@message)).to eq('1')
  end

  it 'maps the time the message was sent to time sent' do
    @message.buffer_update.sent_from_date_time = '27 April 2017 12:00:02'
    expect(TcorsDataReportMapper.time_sent(@message)).to eq('12:00:02')
    @message.buffer_update.sent_from_date_time = nil
    expect(TcorsDataReportMapper.time_sent(@message)).to eq('N/A')
    @message.medium = :ad
    expect(TcorsDataReportMapper.time_sent(@message)).to eq('N/A')
  end

  it 'maps the social media platform to the sm_type' do
    @message.platform = :twitter
    expect(TcorsDataReportMapper.sm_type(@message)).to eq('T')
    @message.platform = :facebook
    expect(TcorsDataReportMapper.sm_type(@message)).to eq('F')
    @message.platform = :instagram
    expect(TcorsDataReportMapper.sm_type(@message)).to eq('I')
  end

  it 'maps the message medium to the medium' do
    expect(TcorsDataReportMapper.medium(@message)).to eq(:organic)
    @message.medium = :ad
    expect(TcorsDataReportMapper.medium(@message)).to eq(:ad)
  end

  it 'maps image_present to the image' do
    expect(TcorsDataReportMapper.image_included(@message)).to eq('No')
    @message.image_present = 'with'
    expect(TcorsDataReportMapper.image_included(@message)).to eq('Yes')
  end

  it 'maps the message total clicks for day 1 to total_clicks_day_1' do
    expect(TcorsDataReportMapper.total_clicks_day_1(@message)).to eq(3)
  end

  it 'maps the message total clicks for day 2 to total_clicks_day_2' do
    expect(TcorsDataReportMapper.total_clicks_day_2(@message)).to eq(1)
  end

  it 'maps the message total clicks for day 3 to total_clicks_day_3' do
    expect(TcorsDataReportMapper.total_clicks_day_3(@message)).to eq(2)
  end

  it 'maps the message total human clicks for the entire experiment to total_clicks_experiment' do
    expect(TcorsDataReportMapper.total_clicks_experiment(@message)).to eq(6)
  end

  it 'maps the times of each human click per tracking link to click_time' do
    expect(TcorsDataReportMapper.click_time(@message)).to eq([["12:23:13", "12:23:13", "12:23:13"], ["13:44:56"], ["19:26:01", "19:26:01"]])
  end
<<<<<<< HEAD
  
  describe 'impressions by date' do
=======
 
  describe 'impressions by day' do
>>>>>>> 5ebe1184a6407b6d93fa40a9aca90f078f7f33c9
    before do
      @message.impressions_by_day = { @message.scheduled_date_time.to_date => 100, (@message.scheduled_date_time + 1.day).to_date => 115, (@message.scheduled_date_time + 2.day).to_date => 120 }
      @message.save
    end

    it 'maps the total impressions for day 1 to total_impressions_day_1' do
      expect(TcorsDataReportMapper.total_impressions_day_1(@message)).to eq(100)
      @message.medium = :ad
      expect(TcorsDataReportMapper.total_impressions_day_1(@message)).to eq(100)
    end

    it 'returns zero for data that is missing' do
      @message.impressions_by_day = {}

      expect(TcorsDataReportMapper.total_impressions_day_1(@message)).to eq(0)
      @message.medium = :ad
      expect(TcorsDataReportMapper.total_impressions_day_1(@message)).to eq(0)
    end

    it 'maps the total impressions to day 2 to total_impressions_day_2' do
      expect(TcorsDataReportMapper.total_impressions_day_2(@message)).to eq(15)
      @message.medium = :ad
      expect(TcorsDataReportMapper.total_impressions_day_2(@message)).to eq(115)
    end

    it 'returns zero for data that is missing for either day 1 or day 2' do
      @message.impressions_by_day = { }
      expect(TcorsDataReportMapper.total_impressions_day_2(@message)).to eq(0)
      @message.medium = :ad
      expect(TcorsDataReportMapper.total_impressions_day_2(@message)).to eq(0)

      @message.impressions_by_day = {(@message.scheduled_date_time + 1.day).to_date => 1 }

      expect(TcorsDataReportMapper.total_impressions_day_2(@message)).to eq(1)
      @message.medium = :ad
      expect(TcorsDataReportMapper.total_impressions_day_2(@message)).to eq(1)
    end

    it 'maps the total impressions for each day to total_impressions_day_3' do
      @message.medium = :organic
      expect(TcorsDataReportMapper.total_impressions_day_3(@message)).to eq(5)
      @message.medium = :ad
      expect(TcorsDataReportMapper.total_impressions_day_3(@message)).to eq(120)
    end

    it 'returns zero for data that is missing for either day 2 or day 3' do
      @message.impressions_by_day = { }
      expect(TcorsDataReportMapper.total_impressions_day_3(@message)).to eq(0)
      @message.medium = :ad
      expect(TcorsDataReportMapper.total_impressions_day_3(@message)).to eq(0)

      @message.medium = :organic
      @message.impressions_by_day = { (@message.scheduled_date_time + 2.day).to_date => 1 }

      expect(TcorsDataReportMapper.total_impressions_day_3(@message)).to eq(1)
      @message.medium = :ad
      expect(TcorsDataReportMapper.total_impressions_day_3(@message)).to eq(1)
    end
  end

  describe 'twitter metrics' do
    before do
      @message.metrics << Metric.new(source: :twitter, data: { 'retweets' => 12 , 'replies'=> 3, 'likes'=> 14 })
      @message.save
    end

    it 'maps the number of twitter shares to retweets_twitter' do
      expect(TcorsDataReportMapper.retweets_twitter(@message)).to eq(12)
    end

    it 'maps the number of twitter likes to likes_twitter' do
      expect(TcorsDataReportMapper.likes_twitter(@message)).to eq(14)
    end

    it 'maps the number of twitter replies to replies_twitter' do
      expect(TcorsDataReportMapper.replies_twitter(@message)).to eq(3)
    end
  end

  describe 'facebook metrics' do
    before do
      @message.metrics << Metric.new(source: :facebook, data: {'shares' => 1 , 'comments'=> 4, 'likes'=> 14 })
      @message.save
    end

    it 'maps the number of facebook shares to share_facebook' do
      expect(TcorsDataReportMapper.shares_facebook(@message)).to eq(1)
    end

    it 'maps the number of facebook likes to likes_facebook' do
      expect(TcorsDataReportMapper.likes_facebook(@message)).to eq(14)
    end

    it 'maps the number of facebook comments to comment_facebook' do
      expect(TcorsDataReportMapper.comments_facebook(@message)).to eq(4)
    end
  end

  describe 'instagram metrics' do
    before do
      @message.metrics << Metric.new(source: :instagram, data: { 'shares' => 0 , 'comments'=> 1, 'likes'=> 24 })
      @message.save
    end

    it 'maps the number of instagram shares to shares_instagram' do
      expect(TcorsDataReportMapper.shares_instagram(@message)).to eq(0)
    end

    it 'maps the number of instagram comments to comments_instagram' do
      expect(TcorsDataReportMapper.comments_instagram(@message)).to eq(1)
    end

    it 'maps the number of instagram likes to likes_instagram' do
      expect(TcorsDataReportMapper.likes_instagram(@message)).to eq(24)
    end
  end

  it 'maps the number of sessions on day 1 to total_sessions_day_1' do
    expect(TcorsDataReportMapper.total_sessions_day_1(@message)).to eq(3)
  end

  it 'maps the number of sessions on day 2 to total_sessions_day_2' do
    expect(TcorsDataReportMapper.total_sessions_day_2(@message)).to eq(2)
  end

  it 'maps the number of sessions on day 3 to total_sessions_day_3' do
    create_list(:visit, 1, utm_content: @message.to_param, started_at: @message.scheduled_date_time + 2.day + 1.hour)
    expect(TcorsDataReportMapper.total_sessions_day_3(@message)).to eq(1)
  end

  it 'ignores the IP address from the list of TCORS addresses' do
    expect(TcorsDataReportMapper.total_sessions_day_3(@message)).to eq(0)
  end

  it 'maps the number of sessions for the whole experiment to total_sessions_experiment' do
    expect(TcorsDataReportMapper.total_sessions_experiment(@message)).to eq(2)
  end

  it 'maps the number of conversions for day 1 to each website link to total_goals_day1' do  
    expect(TcorsDataReportMapper.total_goals_day_1(@message)).to eq(3)
  end

  it 'maps the number of conversions for day 2 to each website link to total_goals_day2' do  
    expect(TcorsDataReportMapper.total_goals_day_2(@message)).to eq(2)
  end

  it 'maps the number of conversions for day 3 to each website link to total_goals_day3' do  
    expect(TcorsDataReportMapper.total_goals_day_3(@message)).to eq(0)
  end

  it 'maps the number of conversions for the duration of the experiment to total_goals_experiment' do
    expect(TcorsDataReportMapper.total_goals_experiment(@message)).to eq(5)
    create_list(:visit, 1, utm_content: @message.to_param, started_at: @message.scheduled_date_time + 2.day + 1.hour)
    expect(TcorsDataReportMapper.total_goals_experiment(@message)).to eq(6)
  end

  it 'maps the number of users for each website to users' do
    expect(TcorsDataReportMapper.users(@message)).to eq(2)
  end

  it 'maps the number of website exits for each website to exits' do
    expect(TcorsDataReportMapper.exits(@message)).to eq(2)
  end

  it 'maps the duration of the user sessions for each website to session_duration' do
    expect(TcorsDataReportMapper.session_duration(@message)).to eq(42)
  end

  it 'maps the time on each webpage for each website to time_onpage' do
    expect(TcorsDataReportMapper.time_on_page(@message)).to eq(42)
  end

  it 'maps the number of page views for each website to pageviews' do
    expect(TcorsDataReportMapper.pageviews(@message)).to eq(2)
  end
end
