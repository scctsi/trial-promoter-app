require 'rails_helper'

RSpec.describe CsvFileReader do
  it 'successfully reads a CSV file from a public URL' do
    csv_url = 'http://sc-ctsi.org/trial-promoter/message_templates.csv'
    sample_csv_content = [["content", "platforms", "hashtags", "tag_list", "website_url", "website_name"], ["This is the first message template.", "twitter", "#hashtag1, #hashtag2", "theme-1, stem-1", "http://www.url1.com", "Smoking cessation"], ["This is the second message template.", "twitter", "#hashtag1, #hashtag2", "theme-1, stem-2", "http://www.url2.com", "Smoking cessation"]]
    csv_content = ''

    VCR.use_cassette 'csv_file_reader/read' do
      csv_content = CsvFileReader.read(csv_url)
    end

    expect(csv_content).to eq(sample_csv_content)
  end

  it 'successfully reads a CSV file which raises an illegal quoting error from a URL (Facebook organic data, which has two header rows)' do
    csv_url = 'https://s3-us-west-1.amazonaws.com/scctsi-tp-production/analytics/Facebook+Insights+Data+Export+%2528Post+Level%2529+-+Be+Free+of+Tobacco+-+2017-07-19.csv'
    csv_content = ''

    VCR.use_cassette 'csv_file_reader/read_with_illegal_quoting' do
      csv_content = CsvFileReader.read(csv_url, {:skip_first_row => true})
    end

    expect(csv_content.count).to eq(267)
  end

  describe "(development only tests)", :development_only_tests => true do
    it 'successfully reads a CSV file from a private Dropbox file path' do
      dropbox_file_path = '/tcors/analytics_files/04-19-2017/tweet_activity_metrics_BeFreeOfTobacco_20170419_20170421_en.csv'
      parsed_csv_content = ''
      
      VCR.use_cassette 'csv_file_reader/read_from_dropbox' do
        parsed_csv_content = CsvFileReader.read_from_dropbox(dropbox_file_path)
      end
  
      expect(parsed_csv_content.size).to eq(4)
      expect(parsed_csv_content[1]).to eq(["854847321003175936", "https://twitter.com/BeFreeOfTobacco/status/854847321003175936", "#Tobacco use causes 1300 US deaths daily-more than AIDS, alcohol, car accidents, homicides &amp; illegal drugs combined https://t.co/hhkUqOfcCS https://t.co/ZG35eVTqLy", "2017-04-20 00:00 +0000", "51.0", "0.0", "0.0", "0.0", "0.0", "0.0", "0.0", "0.0", "0.0", "0.0", "0.0", "0", "0", "0", "0", "0", "0", "0", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"])
    end
  end
end