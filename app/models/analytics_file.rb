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

class AnalyticsFile < ActiveRecord::Base
  extend Enumerize

  validates :social_media_profile, presence: true
  validates :required_upload_date, presence: true
  validates :message_generating, presence: true
  enumerize :processing_status, in: [:unprocessed, :processed], default: :unprocessed

  belongs_to :social_media_profile
  belongs_to :message_generating, polymorphic: true

  def process
    return if processing_status == :processed

    # Step 1: Read file from the file's URL. Based on the filename, read in CSV or Excel data.
    # For Facebook organic data (Facebook Insights), the file has two headers rows.
    # In order to process the file successfully, we need to skip the first row.
    if url.ends_with?('.csv')
      if social_media_profile.platform == :facebook && social_media_profile.allowed_mediums == [:organic]
        content = CsvFileReader.read(url, {:skip_first_row => true})
      else
        content = CsvFileReader.read(url)
      end
    end
    content = ExcelFileReader.new.read(url) if url.ends_with?('.xlsx')

    # Step 2: Convert this to parseable data (An OpenStruct with an array of column headers and an array of rows with the metric data)
    parseable_data = AnalyticsDataParser.convert_to_parseable_data(content, social_media_profile.platform, social_media_profile.allowed_mediums[0])

    # Step 3: Apply any transforms needed to the parseable data based on platform and medium
    case social_media_profile.platform
    when :twitter
      case social_media_profile.allowed_mediums[0]
      when :organic
        AnalyticsDataParser.transform(parseable_data, {:operation => :parse_tweet_id_from_permalink, :permalink_column_index => 1})
      end
    end

    # Step 4: Parse the data (into a hash that uses the message params as the keys and the values as the metrics for that message in a hash)
    if social_media_profile.platform == :facebook && social_media_profile.allowed_mediums == [:ad] || social_media_profile.platform == :instagram && social_media_profile.allowed_mediums == [:ad]
      parsed_data = AnalyticsDataParser.parse(parseable_data, 'campaign_id')
    else
      parsed_data = AnalyticsDataParser.parse(parseable_data)
    end

    # Step 5: Persist the metrics data
    AnalyticsDataParser.store(parsed_data, social_media_profile.platform)
    self.processing_status = :processed
    save
  end
end
