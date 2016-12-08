require 'rails_helper'

RSpec.describe CsvFileReader do
  before do
    @csv_file_reader = CsvFileReader.new
  end
  
  it 'successfully reads a CSV file from a URL' do
    csv_url = 'http://sc-ctsi.org/trial-promoter/message_templates.csv'
    sample_csv_content = [["content", "platform", "hashtags", "tag_list", "website_url", "website_name"], ["This is the first message template.", "twitter", "#hashtag1, #hashtag2", "theme-1, stem-1", "http://www.url1", "Smoking cessation"], ["This is the second message template.", "twitter", "#hashtag1, #hashtag2", "theme-1, stem-2", "http://www.url1", "Smoking cessation"]]
    csv_content = ''
    
    VCR.use_cassette 'csv_file_reader/read' do
      csv_content = @csv_file_reader.read(csv_url)
    end

    expect(csv_content).to eq(sample_csv_content)
  end
end
