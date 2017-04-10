require 'rails_helper'

RSpec.describe CsvFileReader do
  it 'successfully reads a CSV file from a URL' do
    csv_url = 'http://sc-ctsi.org/trial-promoter/message_templates.csv'
    sample_csv_content = [["content", "platforms", "hashtags", "tag_list", "website_url", "website_name"], ["This is the first message template.", "twitter", "#hashtag1, #hashtag2", "theme-1, stem-1", "http://www.url1.com", "Smoking cessation"], ["This is the second message template.", "twitter", "#hashtag1, #hashtag2", "theme-1, stem-2", "http://www.url2.com", "Smoking cessation"]]
    csv_content = ''
    
    VCR.use_cassette 'csv_file_reader/read' do
      csv_content = CsvFileReader.read(csv_url)
    end

    expect(csv_content).to eq(sample_csv_content)
  end
end