require 'rails_helper'

RSpec.describe TcorsDataReportMapper do
  before do
    @message = create(:message)
    @message.scheduled_date_time = '30 April 2017 12:00:00'
    @message.click_meter_tracking_link = create(:click_meter_tracking_link)
    @message.click_meter_tracking_link.clicks << create_list(:click, 3, :unique => '1', :click_time => "30 April 2017 00:23:13")
    @message.click_meter_tracking_link.clicks << create_list(:click, 1, :spider => '1', :click_time => "1 May 2017 12:34:57")
    @message.click_meter_tracking_link.clicks << create_list(:click, 1, :unique => '1', :click_time => "1 May 2017 13:44:56")
    @message.click_meter_tracking_link.clicks << create_list(:click, 2, :unique => '1', :click_time => "2 May 2017 19:26:01")

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
      @message.message_template.experiment_variables['theme'] = ['1','2']
      expect(TcorsDataReportMapper.theme(@message)).to eq('Health, Community')
      @message.message_template.experiment_variables['theme'] = ['3']
      expect(TcorsDataReportMapper.theme(@message)).to eq('Money')
      @message.message_template.experiment_variables['theme'] = ['4']
      expect(TcorsDataReportMapper.theme(@message)).to eq('Family')
      @message.message_template.experiment_variables['theme'] = ['5']
      expect(TcorsDataReportMapper.theme(@message)).to eq('Addiction')
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
      @message.message_template.experiment_variables['lin_meth_level'] = '1'
      expect(TcorsDataReportMapper.lin_meth_level(@message)).to eq('You')
      @message.message_template.experiment_variables['lin_meth_level'] = '2'
      expect(TcorsDataReportMapper.lin_meth_level(@message)).to eq('We')
      @message.message_template.experiment_variables['lin_meth_level'] = '3'
      expect(TcorsDataReportMapper.lin_meth_level(@message)).to eq('Everyone/Anyone')
      @message.message_template.experiment_variables['lin_meth_level'] = '4'
      expect(TcorsDataReportMapper.lin_meth_level(@message)).to eq('Specific new information mentioned first')
      @message.message_template.experiment_variables['lin_meth_level'] = '5'
      expect(TcorsDataReportMapper.lin_meth_level(@message)).to eq('Specific new information mentioned last')
      @message.message_template.experiment_variables['lin_meth_level'] = '6'
      expect(TcorsDataReportMapper.lin_meth_level(@message)).to eq('Raw numbers')
      @message.message_template.experiment_variables['lin_meth_level'] = '7'
      expect(TcorsDataReportMapper.lin_meth_level(@message)).to eq('Percentage')
      @message.message_template.experiment_variables['lin_meth_level'] = '8'
      expect(TcorsDataReportMapper.lin_meth_level(@message)).to eq('Specific new information mentioned first and raw numbers')
      @message.message_template.experiment_variables['lin_meth_level'] = '9'
      expect(TcorsDataReportMapper.lin_meth_level(@message)).to eq('Specific new information mentioned first and percentage')
      @message.message_template.experiment_variables['lin_meth_level'] = '10'
      expect(TcorsDataReportMapper.lin_meth_level(@message)).to eq('Specific new information mentioned last and raw numbers')
      @message.message_template.experiment_variables['lin_meth_level'] = '11'
      expect(TcorsDataReportMapper.lin_meth_level(@message)).to eq('Specific new information mentioned last and percentage')
    end
  end

  it 'maps the social media platform to the message' do
    @message.platform = :twitter
    expect(TcorsDataReportMapper.sm_type(@message)).to eq('T')
    @message.platform = :facebook
    expect(TcorsDataReportMapper.sm_type(@message)).to eq('F')
    @message.platform = :instagram
    expect(TcorsDataReportMapper.sm_type(@message)).to eq('I')
  end

  it 'maps the message content to the variant' do
    expect(TcorsDataReportMapper.variant(@message)).to eq('Content')
  end

  it 'maps the scheduled date of the message to the day of the experiment' do
    expect(TcorsDataReportMapper.day_experiment(@message)).to eq(11)
  end

  it 'maps the date the message was published to the date sent' do
    expect(TcorsDataReportMapper.date_sent(@message)).to eq('30 April 2017 12:00:00')
  end

  it 'maps the date the message was published to the day of the week' do
    expect(TcorsDataReportMapper.day_sent(@message)).to eq('Sunday')
    @message.scheduled_date_time = '29 April 2017 12:00:00'
    @message.click_meter_tracking_link.clicks.each{|click| click.unique = true }
    expect(TcorsDataReportMapper.day_sent(@message)).to eq('Saturday')
    @message.scheduled_date_time = '28 April 2017 12:00:00'
    expect(TcorsDataReportMapper.day_sent(@message)).to eq('Friday')
    @message.scheduled_date_time = '27 April 2017 12:00:00'
    expect(TcorsDataReportMapper.day_sent(@message)).to eq('Thursday')
    @message.scheduled_date_time = '26 April 2017 12:00:00'
    expect(TcorsDataReportMapper.day_sent(@message)).to eq('Wednesday')
    @message.scheduled_date_time = '25 April 2017 12:00:00'
    expect(TcorsDataReportMapper.day_sent(@message)).to eq('Tuesday')
    @message.scheduled_date_time = '24 April 2017 12:00:00'
    expect(TcorsDataReportMapper.day_sent(@message)).to eq('Monday')
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

  it 'maps the message total clicks for day 1 to total_clicks_day1' do
    expect(TcorsDataReportMapper.total_clicks_day1(@message)).to eq(3)
  end

  it 'maps the message total clicks for day 2 to total_clicks_day2' do
    expect(TcorsDataReportMapper.total_clicks_day2(@message)).to eq(1)
  end

  it 'maps the message total clicks for day 3 to total_clicks_day3' do
    expect(TcorsDataReportMapper.total_clicks_day3(@message)).to eq(2)
  end

  it 'maps the message total human clicks for the entire experiment to total_clicks_experiment' do
    expect(TcorsDataReportMapper.total_clicks_experiment(@message)).to eq(6)
  end

  it 'maps the times of each human click per tracking link to click_time' do
    expect(TcorsDataReportMapper.click_time(@message)).to eq(['2017-04-30 00:23:13.000000000 +0000', '2017-04-30 00:23:13.000000000 +0000', '2017-04-30 00:23:13.000000000 +0000','2017-05-01 13:44:56.000000000 +0000',
      '2017-05-02 19:26:01.000000000 +0000','2017-05-02 19:26:01.000000000 +0000'])
    expect(TcorsDataReportMapper.click_time(@message)).to_not eq([ '2017-05-01 12:34:57.000000000 +0000'])
  end

  xit 'maps the total impressions for each day to total_impressions_day1' do
    expect(TcorsDataReportMapper.total_impressions_day1(@message).to eq(1000))
  end

  xit 'maps the total impressions for each day to total_impressions_day2' do
    expect(TcorsDataReportMapper.total_impressions_day2(@message).to eq(800))
  end

  xit 'maps the total impressions for each day to total_impressions_day3' do
    expect(TcorsDataReportMapper.total_impressions_day3(@message).to eq(400))
  end
end