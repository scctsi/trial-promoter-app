class DataDictionary < ActiveRecord::Base
  belongs_to :experiment
  validates :experiment, presence: true
  
  has_many :data_dictionary_entries

  DATA_ELEMENTS = {
    :facebook => ['impressions, shares, comments, likes'],
    :instagram => ['impressions, reposts, comments, likes'],
    :trial_promoter => ['ordinal_day, date_set, day_of_week_sent, time_sent, platform, medium, image_used, tags, link_clicks, click_time'],
    :twitter => ['impressions, retweets, replies, likes']
  }
end
