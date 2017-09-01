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

  describe "(development only tests)", :development_only_tests => true do
    before do
      secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
      allow(Setting).to receive(:[]).with(:dropbox_access_token).and_return(secrets['dropbox_access_token'])
      @dropbox_client = DropboxClient.new
    end
    
    it 'converts a hierarchical list of folders and files to a processable list by converting folder names to dates and removing files it should ignore' do
      folders_and_files = nil
      VCR.use_cassette 'daily_metric_parser/convert_to_processable_list' do
        folders_and_files = @dropbox_client.recursively_list_folder('/TCORS/analytics_files/')
      end
      
      filtered_folders_and_files = @daily_metric_parser.convert_to_processable_list(folders_and_files)
      
      expect(filtered_folders_and_files.keys.count).to eq(91)
      filtered_folders_and_files.each do |folder, files|
        expect(folder).to be_an_instance_of(Date)
        expect(files.count).to eq(4)
      end
    end
  
    it 'converts a CSV file into a hash of message identifiers and metric values given two column indices' do
      parsed_metrics = {}
      
      VCR.use_cassette 'daily_metric_parser/parse_metric_from_csv_file' do
        parsed_metrics = @daily_metric_parser.parse_metric_from_file('/tcors/analytics_files/04-19-2017/tweet_activity_metrics_BeFreeOfTobacco_20170419_20170421_en.csv', 0, 4)
      end
  
      expect(parsed_metrics.length).to eq(3)
      parsed_metrics.each do |key, value|
        expect(key).to be_an_instance_of(String)
        expect(value).to be_an_instance_of(Fixnum)
      end
    end
    
    it 'converts an Excel file into a hash of message identifiers and metric values given two column indices' do
      parsed_metrics = {}
      
      VCR.use_cassette 'daily_metric_parser/parse_metric_from_excel_file' do
        parsed_metrics = @daily_metric_parser.parse_metric_from_file('/tcors/analytics_files/04-19-2017/2017-04-19-to-2017-04-19-6tpc94axlwcg.xlsx', 6, 8)
      end
  
      expect(parsed_metrics.length).to eq(3)
      parsed_metrics.each do |key, value|
        expect(key).to be_an_instance_of(String)
        expect(value).to be_an_instance_of(Fixnum)
      end
    end

    it 'returns the column indices for the metric value and the identifier given a TCOS file name' do
      expect(@daily_metric_parser.column_indices('2017-04-19-to-2017-04-19-6hu9ou4xpw5c.xlsx')).to eq([6, 8])
      expect(@daily_metric_parser.column_indices('Facebook Insights Data Export (Post Level) - Be Free of Tobacco - 2017-04-20')).to eq([0, 11])
      expect(@daily_metric_parser.column_indices('Tommy-Trogan-All-Campaigns-Apr-19-2017-_-Apr-20-2017')).to eq([2, 3])
      expect(@daily_metric_parser.column_indices('tweet_activity_metrics_BeFreeOfTobacco_20170419_20170421_en')).to eq([0, 4])
    end
    
    it 'logs the metrics parsed from a file' do
      @daily_metric_parser.log_parsed_metrics('/TCORS/analytics_files/04-20-2017/file.csv', Date.new(2017, 4, 19), {"100" => 500, "200" => 600})

      expect(DailyMetricParserResult.count).to eq(1)
      daily_metric_parser_result = DailyMetricParserResult.first
      expect(daily_metric_parser_result.file_date).to eq(Date.new(2017, 4, 19))
      expect(daily_metric_parser_result.file_path).to eq('/TCORS/analytics_files/04-20-2017/file.csv')
      expect(daily_metric_parser_result.parsed_data).to eq({"100" => 500, "200" => 600})
    end
    
    it 'replaces the parsed_data in a logged metric parse result for the same file_date and file_path' do
      @daily_metric_parser.log_parsed_metrics('/TCORS/analytics_files/04-20-2017/file.csv', Date.new(2017, 4, 19), {"100" => 500, "200" => 600})
      @daily_metric_parser.log_parsed_metrics('/TCORS/analytics_files/04-20-2017/file.csv', Date.new(2017, 4, 19), {"100" => 700, "200" => 800})

      expect(DailyMetricParserResult.count).to eq(1)
      daily_metric_parser_result = DailyMetricParserResult.first
      expect(daily_metric_parser_result.file_date).to eq(Date.new(2017, 4, 19))
      expect(daily_metric_parser_result.file_path).to eq('/TCORS/analytics_files/04-20-2017/file.csv')
      expect(daily_metric_parser_result.parsed_data).to eq({"100" => 700, "200" => 800})
    end
  end
end