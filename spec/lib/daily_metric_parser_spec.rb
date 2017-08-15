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
  
  it 'extracts all the values from two columns in a file given the column indices as a hash' do
    
  end
end