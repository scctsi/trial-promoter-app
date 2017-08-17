require 'rails_helper'
require 'google/apis/analytics_v3'

RSpec.describe TcorsDataReportMapper do
  before do
    @message = create(:message)
    @message.scheduled_date_time = '30 April 2017 12:00:00'
    visits_1 = create_list(:visit, 3, utm_content: @message.to_param, started_at: @message.scheduled_date_time + 1.hour)
    visits_2 = create_list(:visit, 2, utm_content: @message.to_param, started_at: @message.scheduled_date_time + 1.day + 1.hour)
    visits_3 = create_list(:visit, 1, utm_content: @message.to_param, started_at: @message.scheduled_date_time + 2.day + 1.hour, ip: '128.125.77.139')
    visits_1.each do |visit|
      visit.ahoy_events << Ahoy::Event.new(visit_id: visit.id)
    end
    @message.click_meter_tracking_link = create(:click_meter_tracking_link)
    @message.click_meter_tracking_link.clicks << create_list(:click, 3, :unique => '1', :click_time => "30 April 2017 00:23:13")
    @message.click_meter_tracking_link.clicks << create_list(:click, 1, :spider => '1', :click_time => "1 May 2017 12:34:57")
    @message.click_meter_tracking_link.clicks << create_list(:click, 1, :unique => '1', :click_time => "1 May 2017 13:44:56")
    @message.click_meter_tracking_link.clicks << create_list(:click, 2, :unique => '1', :click_time => "2 May 2017 19:26:01")
    # @message.impressions_by_day = [300, 800, 1400, 10000]

    @message.metrics << Metric.new(source: :google_analytics, data: {'ga:sessions'=>2, 'ga:users'=>2, 'ga:exits' =>2, 'ga:sessionDuration' => [42, 18], 'ga:timeOnPage' => [42, 18], 'ga:pageviews' => 2})

    @message.website_session_count = 34
    @message.save
  end

  describe 'experiment variables mapping methods' do
    it 'maps the message stem_id to stem' do
      @message.message_template.experiment_variables['stem_id'] = 'FE51'
      expect(TcorsDataReportMapper.stem(@message)).to eq('FE51')
    end

    it 'maps the message fda_campaign to fda_campaign' do
      @message.message_template.experiment_variables['fda_campaign'] = '1'
      expect(TcorsDataReportMapper.fda_campaign(@message)).to eq('Fresh Empire')
      @message.message_template.experiment_variables['fda_campaign'] = '2'
      expect(TcorsDataReportMapper.fda_campaign(@message)).to eq('This Free Life')
    end

    it 'maps the message theme to theme' do
      @message.message_template.experiment_variables['theme'] = '1'
      expect(TcorsDataReportMapper.theme(@message)).to eq('Health')
      @message.message_template.experiment_variables['theme'] = '2'
      expect(TcorsDataReportMapper.theme(@message)).to eq('Appearance')
      @message.message_template.experiment_variables['theme'] = '3'
      expect(TcorsDataReportMapper.theme(@message)).to eq('Money')
      @message.message_template.experiment_variables['theme'] = '4'
      expect(TcorsDataReportMapper.theme(@message)).to eq('Love of Family')
      @message.message_template.experiment_variables['theme'] = '5'
      expect(TcorsDataReportMapper.theme(@message)).to eq('Addiction')
      @message.message_template.experiment_variables['theme'] = '6'
      expect(TcorsDataReportMapper.theme(@message)).to eq('Health + Community')
      @message.message_template.experiment_variables['theme'] = '7'
      expect(TcorsDataReportMapper.theme(@message)).to eq('Health + Family')
    end

    it 'maps the message experiment variable to lin_meth_factor' do
      @message.message_template.experiment_variables['lin_meth_factor'] = '1'
      expect(TcorsDataReportMapper.lin_meth_factor(@message)).to eq('Perspective taking')
      @message.message_template.experiment_variables['lin_meth_factor'] = '2'
      expect(TcorsDataReportMapper.lin_meth_factor(@message)).to eq('Information packaging')
      @message.message_template.experiment_variables['lin_meth_factor'] = '3'
      expect(TcorsDataReportMapper.lin_meth_factor(@message)).to eq('Numeracy')
      @message.message_template.experiment_variables['lin_meth_factor'] = '4'
      expect(TcorsDataReportMapper.lin_meth_factor(@message)).to eq('Information packaging x Numeracy')
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
    expect(TcorsDataReportMapper.day_experiment(@message)).to eq(11)
  end

  it 'maps the date the message was published to the date sent' do
    expect(TcorsDataReportMapper.date_sent(@message)).to eq('04/30/2017')
  end

  it 'maps the date the message was published to the day of the week' do
    expect(TcorsDataReportMapper.day_sent(@message)).to eq('7')
    @message.scheduled_date_time = '29 April 2017 12:00:00'
    @message.click_meter_tracking_link.clicks.each{|click| click.unique = true }
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
    expect(TcorsDataReportMapper.time_sent(@message)).to eq('12:00:00')
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
    expect(TcorsDataReportMapper.click_time(@message)).to eq(['00:23:13', '00:23:13', '00:23:13', '13:44:56', '19:26:01', '19:26:01'])
    expect(TcorsDataReportMapper.click_time(@message)).to_not eq([ '2017-05-01 12:34:57.000000000'])
  end

  # it 'maps the total impressions for each day to total_impressions_day_1' do
  #   expect(TcorsDataReportMapper.total_impressions_day_1(@message)).to eq(300)
  #   @message.medium = :ad
  #   expect(TcorsDataReportMapper.total_impressions_day_1(@message)).to eq(300)
  # end

  # it 'maps the total impressions for each day to total_impressions_day_2' do
  #   expect(TcorsDataReportMapper.total_impressions_day_2(@message)).to eq(500)
  #   @message.medium = :ad
  #   @message.impressions_by_day = [300, 800, 1400, 10000]
  #   expect(TcorsDataReportMapper.total_impressions_day_2(@message)).to eq(800)
  # end

  # it 'maps the total impressions for each day to total_impressions_day_3' do
  #   expect(TcorsDataReportMapper.total_impressions_day_3(@message)).to eq(600)
  #   @message.medium = :ad
  #   @message.impressions_by_day = [300, 800, 1400, 10000]
  #   expect(TcorsDataReportMapper.total_impressions_day_3(@message)).to eq(1400)
  # end

  # it 'maps the total impressions for the entire experiment to total_impressions_experiment' do
  #   expect(TcorsDataReportMapper.total_impressions_experiment(@message)).to eq(10000)
  # end

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
    expect(TcorsDataReportMapper.total_sessions_experiment(@message)).to eq(34)
  end

  it 'maps the number of google analytics sessions for each website to sessions' do
    expect(TcorsDataReportMapper.sessions(@message)).to eq(2)
  end

  it 'maps the number of clicks for each website link to clicks' do
    #excludes one of the TCORS members clicks
    expect(TcorsDataReportMapper.clicks(@message)).to eq(5)
    visits_3 = create_list(:visit, 1, utm_content: @message.to_param, started_at: @message.scheduled_date_time + 2.day + 1.hour)
    expect(TcorsDataReportMapper.clicks(@message)).to eq(6)
  end

  it 'maps the number of users for each website to users' do
    expect(TcorsDataReportMapper.users(@message)).to eq(2)
  end

  it 'maps the number of website exits for each website to exits' do
    expect(TcorsDataReportMapper.exits(@message)).to eq(2)
  end

  it 'maps the duration of the user sessions for each website to session_duration' do
    expect(TcorsDataReportMapper.session_duration(@message)).to eq([42,18])
  end

  it 'maps the time on each webpage for each website to time_onpage' do
    expect(TcorsDataReportMapper.time_on_page(@message)).to eq([42, 18])
  end

  it 'maps the number of page views for each website to pageviews' do
    expect(TcorsDataReportMapper.pageviews(@message)).to eq(2)
  end
end