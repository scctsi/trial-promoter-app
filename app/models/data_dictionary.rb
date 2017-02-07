# == Schema Information
#
# Table name: data_dictionaries
#
#  id            :integer          not null, primary key
#  experiment_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class DataDictionary < ActiveRecord::Base
  belongs_to :experiment
  validates :experiment, presence: true
  
  has_many :data_dictionary_entries

  DATA_ELEMENTS = {
    :facebook => ['impressions', 'shares', 'comments', 'likes'].sort,
    :google_analytics => ['sessions', 'users', 'exits', 'shares', 'comments', 'likes'].sort,
    :instagram => ['impressions', 'reposts', 'comments', 'likes'].sort,
    :trial_promoter => ['ordinal_day', 'date_set', 'day_of_week_sent', 'time_sent', 'platform, medium', 'image_used', 'tags', 'link_clicks', 'click_time'].sort,
    :twitter => ['impressions', 'retweets', 'replies', 'likes'].sort
  }
end
