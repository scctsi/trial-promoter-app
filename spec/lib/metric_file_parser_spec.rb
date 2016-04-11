require 'rails_helper'

RSpec.describe MetricFileParser do
  before do
    @metric_file_parser = MetricFileParser.new
    twitter_metrics_csv_file_content = <<-CSV
"Tweet id","Tweet permalink","Tweet text","time","impressions","engagements","engagement rate","retweets","replies","favorites","user profile clicks","url clicks","hashtag clicks","detail expands","permalink clicks","app opens","app installs","follows","email tweet","dial phone","media views","media engagements","promoted impressions","promoted engagements","promoted engagement rate","promoted retweets","promoted replies","promoted favorites","promoted user profile clicks","promoted url clicks","promoted hashtag clicks","promoted detail expands","promoted permalink clicks","promoted app opens","promoted app installs","promoted follows","promoted email tweet","promoted dial phone","promoted media views","promoted media engagements"
"649293177409679360","https://twitter.com/USCTrials/status/649293177409679360","Diagnosed with #KidneyCancer? Leading researcher David Quinn @KeckMedUSC is looking for #ClinicalTrial participants http://t.co/gispyAPj8L","2015-09-30 18:42 +0000","424.0","3.0","0.007075471698113208","1.0","2.0","3.0","4.0","5.0","6.0","7.0","8.0","0","0","0","0","0","0","0","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"
"649064976133525504","https://twitter.com/USCTrials/status/649064976133525504","This clinical research study for #GynCSM is now accepting participants http://t.co/ea2ktYDEf9 http://t.co/RIuqAn51Jz","2015-09-30 03:35 +0000","411.0","8.0","0.019464720194647202","0.0","0.0","1.0","1.0","4.0","0.0","2.0","0.0","0","0","0","0","0","0","0","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"
    CSV
    csv = CSV.new(twitter_metrics_csv_file_content)
    @twitter_metrics_csv = csv.read
    @messages = build_list(:message, 5)
    @messages[0].buffer_update = BufferUpdate.new(:buffer_id => "buffer1", :status => :sent, :service_update_id => '649293177409679360')
    @messages[0].save
    @messages[1].buffer_update = BufferUpdate.new(:buffer_id => "buffer2", :status => :sent, :service_update_id => '649064976133525504')
    @messages[1].save
    @messages[2].buffer_update = BufferUpdate.new(:buffer_id => "buffer3", :status => :pending, :service_update_id => nil)
    @messages[2].save
    @messages[3].buffer_update = BufferUpdate.new(:buffer_id => "buffer3", :status => :pending, :service_update_id => '649064976133525599')
    @messages[3].save
  end

  it "parses a line from a metrics file provided by twitter analytics into a metric" do
    metric = @metric_file_parser.to_metric(@twitter_metrics_csv[1], :twitter)

    expect(metric.source).to eq(:twitter)
    expect(metric.data[:impressions]).to eq("424.0")
    expect(metric.data[:engagements]).to eq("3.0")
    expect(metric.data[:engagement_rate]).to eq("0.007075471698113208")
    expect(metric.data[:retweets]).to eq("1.0")
    expect(metric.data[:replies]).to eq("2.0")
    expect(metric.data[:favorites]).to eq("3.0")
    expect(metric.data[:user_profile_clicks]).to eq("4.0")
    expect(metric.data[:url_clicks]).to eq("5.0")
    expect(metric.data[:hashtag_clicks]).to eq("6.0")
    expect(metric.data[:detail_expands]).to eq("7.0")
    expect(metric.data[:permalink_clicks]).to eq("8.0")
  end
  
  it "parses a single line and adds the parsed metric to a specific message based on the service_update_id " do
    @metric_file_parser.parse_line(@twitter_metrics_csv[1], :twitter)
    
    expect(@messages[0].metrics.length).to eq(1)
    expect(@messages[0].metrics[0].source).to eq(:twitter)
    expect(@messages[0].metrics[0].data).not_to be_nil
    expect(@messages[0].persisted?).to be_truthy
  end

  it "parses all the lines from a CSV and adds all parsed metrics to specific messages based on the service_update_id " do
    allow(@metric_file_parser).to receive(:parse_line)
    @metric_file_parser.parse(@twitter_metrics_csv, :twitter)

    expect(@metric_file_parser).to have_received(:parse_line).with(@csv_content[1], :twitter)
    expect(@metric_file_parser).to have_received(:parse_line).with(@csv_content[2], :twitter)
  end
  
  it "reads a CSV file from a URL" do
    csv_content = ''
    
    VCR.use_cassette 'metric_file_parser/read_from_url' do
      csv_content = @metric_file_parser.read_from_url("http://sc-ctsi.org/trial-promoter/tweet_activity_metrics.csv")
    end
  
    expect(csv_content.length).to eq(4)
  end
  
  it "parses a CSV file from a URL" do
    csv_url = "http://sc-ctsi.org/trial-promoter/tweet_activity_metrics.csv"
    csv_content = 'Some content'
    allow(@metric_file_parser).to receive(:read_from_url).and_return(csv_content)
    allow(@metric_file_parser).to receive(:parse)
    
    VCR.use_cassette 'metric_file_parser/parse_from_url' do
      @metric_file_parser.parse_from_url(csv_url, :twitter)
    end
  
    expect(@metric_file_parser).to have_received(:read_from_url).with(csv_url)
    expect(@metric_file_parser).to have_received(:parse).with(csv_content, :twitter)
  end
end