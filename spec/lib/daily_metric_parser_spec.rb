require 'rails_helper'

RSpec.describe DailyMetricParser do
  before do
    @daily_metric_parser = DailyMetricParser.new
  end
  
  it 'converts the name of a folder to a date' do
    date = @daily_metric_parser.name_to_date('04-19-2017')
    
    expect(date.year).to eq(2017)
    expect(date.month).to eq(4)
    expect(date.day).to eq(19)
  end
  
  it 'determines whether an analytics file for TCORS shoule be ignored based on the file name' do
    # For TCORS, we ignore the files that contain the organic data for the ad accounts
    expect(@daily_metric_parser.ignore_file?('2017-04-19-to-2017-04-19-6hu9ou4xpw5c.xlsx')).to be false
    expect(@daily_metric_parser.ignore_file?('Facebook Insights Data Export (Post Level) - B Free of Tobacco - 2017-04-20')).to be true
    expect(@daily_metric_parser.ignore_file?('Facebook Insights Data Export (Post Level) - Be Free of Tobacco - 2017-04-20')).to be false
    expect(@daily_metric_parser.ignore_file?('Tommy-Trogan-All-Campaigns-Apr-19-2017-_-Apr-20-2017')).to be false
    expect(@daily_metric_parser.ignore_file?('tweet_activity_metrics_BeFreeOfTobacco_20170419_20170421_en')).to be false
    expect(@daily_metric_parser.ignore_file?('tweet_activity_metrics_BFreeOfTobacco_20170319_20170421_en_04-19-2017')).to be true
  end
end