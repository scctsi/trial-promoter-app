require 'rails_helper'

RSpec.describe CsvFileReader do
  before do
    @csv_file_reader = CsvFileReader.new
  end

  it 'successfully reads a CSV file from a URL' do
    csv_url = 'http://sc-ctsi.org/trial-promoter/message_templates.csv'
    sample_csv_content = [["content", "platforms", "hashtags", "tag_list", "website_url", "website_name"], ["This is the first message template.", "twitter", "#hashtag1, #hashtag2", "theme-1, stem-1", "http://www.url1.com", "Smoking cessation"], ["This is the second message template.", "twitter", "#hashtag1, #hashtag2", "theme-1, stem-2", "http://www.url2.com", "Smoking cessation"]]
    csv_content = ''

    VCR.use_cassette 'csv_file_reader/read' do
      csv_content = @csv_file_reader.read(csv_url)
    end

    expect(csv_content).to eq(sample_csv_content)
  end

  it 'successfully reads a CSV file with an invalid UTF-8 byte sequence from a URL' do
    csv_url = 'http://sc-ctsi.org/trial-promoter/message_templates_invalid_byte_sequence_in_utf_8.csv'
    csv_content = ''

    VCR.use_cassette 'csv_file_reader/read_invalid_utf_8_byte_sequence' do
      csv_content = @csv_file_reader.read(csv_url)
    end

    expect(csv_content.count).to be > 0
    expect(csv_content[1]).to eq(["#Smoking damages your DNA, which can lead to cancer almost anywhere in your body.", "facebook, instagram, twitter", nil, nil, "sc-ctsi.org", "CTSI [temp]", "health", "FE", "FE53", "1", "1"])
  end
end
