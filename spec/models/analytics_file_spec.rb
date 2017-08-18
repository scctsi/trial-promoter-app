# == Schema Information
#
# Table name: analytics_files
#
#  id                      :integer          not null, primary key
#  url                     :string(2000)
#  original_filename       :string
#  social_media_profile_id :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  required_upload_date    :datetime
#  message_generating_id   :integer
#  message_generating_type :string
#  processing_status       :string
#


require 'rails_helper'

RSpec.describe AnalyticsFile do
  it { is_expected.to validate_presence_of :social_media_profile }
  it { is_expected.to validate_presence_of :required_upload_date }
  it { is_expected.to validate_presence_of :message_generating }
  it { is_expected.to belong_to :social_media_profile }
  it { is_expected.to belong_to :message_generating }
  it { is_expected.to enumerize(:processing_status).in(:unprocessed, :processed).with_default(:unprocessed) }

  before do
    @excel_file_reader = double('excel_file_reader')
    allow(ExcelFileReader).to receive(:new).and_return(@excel_file_reader)
    @analytics_file = create(:analytics_file, url: 'http://url.com', social_media_profile: build(:social_media_profile, allowed_mediums: [:ad]))
    @csv_content = []
    allow(CsvFileReader).to receive(:read).and_return(@csv_content)
    @excel_content = []
    allow(@excel_file_reader).to receive(:read).and_return(@excel_content)
    @parseable_data = []
    allow(AnalyticsDataParser).to receive(:convert_to_parseable_data).and_return(@parseable_data)
    @transformed_data = []
    allow(AnalyticsDataParser).to receive(:transform).and_return(@transformed_data)
    @parsed_data = {}
    allow(AnalyticsDataParser).to receive(:parse).and_return(@parsed_data)
    allow(AnalyticsDataParser).to receive(:store)
  end

  it "processes a file (in CSV format) located at the file's URL" do
    @analytics_file.url = 'http://www.example.com/file.csv'
    @analytics_file.process

    expect(CsvFileReader).to have_received(:read).with(@analytics_file.url)
    expect(AnalyticsDataParser).to have_received(:convert_to_parseable_data).with(@csv_content, @analytics_file.social_media_profile.platform, @analytics_file.social_media_profile.allowed_mediums[0])
    expect(AnalyticsDataParser).to have_received(:parse).with(@parseable_data)
    expect(AnalyticsDataParser).to have_received(:store).with(@parsed_data, @analytics_file.social_media_profile.platform)
    @analytics_file.reload
    expect(@analytics_file.processing_status.value).to eq("processed")
  end

  it "processes a file (in Excel (.xslx) format) located at the file's URL" do
    @analytics_file.url = 'http://www.example.com/file.xlsx'
    @analytics_file.process

    expect(@excel_file_reader).to have_received(:read).with(@analytics_file.url)
    expect(AnalyticsDataParser).to have_received(:convert_to_parseable_data).with(@csv_content, @analytics_file.social_media_profile.platform, @analytics_file.social_media_profile.allowed_mediums[0])
    expect(AnalyticsDataParser).to have_received(:parse).with(@parseable_data)
    expect(AnalyticsDataParser).to have_received(:store).with(@parsed_data, @analytics_file.social_media_profile.platform)
    @analytics_file.reload
    expect(@analytics_file.processing_status.value).to eq("processed")
  end

  it "processes a file for Facebook Insights (organic data) (in CSV format) located at the file's URL" do
    @analytics_file.social_media_profile.allowed_mediums = [:organic]
    @analytics_file.social_media_profile.platform = :facebook
    @analytics_file.url = 'http://www.example.com/file.csv'
    @analytics_file.process

    expect(CsvFileReader).to have_received(:read).with(@analytics_file.url, {:skip_first_row => true})
    expect(AnalyticsDataParser).to have_received(:convert_to_parseable_data).with(@csv_content, @analytics_file.social_media_profile.platform, @analytics_file.social_media_profile.allowed_mediums[0])
    expect(AnalyticsDataParser).to have_received(:parse).with(@parseable_data)
    expect(AnalyticsDataParser).to have_received(:store).with(@parsed_data, @analytics_file.social_media_profile.platform)
    @analytics_file.reload
    expect(@analytics_file.processing_status.value).to eq("processed")
  end

  it "processes a file for Facebook/Instagram Ads (in CSV format) located at the file's URL" do
    @analytics_file.social_media_profile.allowed_mediums = [:ad]
    @analytics_file.social_media_profile.platform = :facebook
    @analytics_file.url = 'http://www.example.com/file.csv'
    @analytics_file.process

    expect(CsvFileReader).to have_received(:read).with(@analytics_file.url)
    expect(AnalyticsDataParser).to have_received(:convert_to_parseable_data).with(@csv_content, @analytics_file.social_media_profile.platform, @analytics_file.social_media_profile.allowed_mediums[0])
    expect(AnalyticsDataParser).to have_received(:parse).with(@parseable_data, 'campaign_id')
    expect(AnalyticsDataParser).to have_received(:store).with(@parsed_data, @analytics_file.social_media_profile.platform)
    @analytics_file.reload
    expect(@analytics_file.processing_status.value).to eq("processed")
  end

  it 'does not process an already processed file' do
    @analytics_file.processing_status = :processed
    @analytics_file.save

    @analytics_file.process

    expect(CsvFileReader).not_to have_received(:read).with(@analytics_file.url)
    expect(AnalyticsDataParser).not_to have_received(:convert_to_parseable_data).with(@csv_content, @analytics_file.social_media_profile.platform, @analytics_file.social_media_profile.allowed_mediums[0])
    expect(AnalyticsDataParser).not_to have_received(:parse).with(@parseable_data)
    expect(AnalyticsDataParser).not_to have_received(:store).with(@parsed_data, @analytics_file.social_media_profile.platform)
    @analytics_file.reload
    expect(@analytics_file.processing_status.value).to eq("processed")
  end

  describe 'applying transformations' do
    it 'applies a transform for files uploaded for organic twitter accounts' do
      @analytics_file.social_media_profile.allowed_mediums = [:organic]
      @analytics_file.social_media_profile.platform = :twitter

      @analytics_file.process

      expect(AnalyticsDataParser).to have_received(:transform).with(@parseable_data, {:operation => :parse_tweet_id_from_permalink, :permalink_column_index => 1})
    end
  end
end
