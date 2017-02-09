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
  accepts_nested_attributes_for :data_dictionary_entries

  DATA_ELEMENTS = {
    :facebook => ['impressions', 'shares', 'comments', 'likes'].sort,
    :google_analytics => ['sessions', 'users', 'exits', 'session_duration', 'time_on_page', 'pageviews'].sort,
    :instagram => ['impressions', 'reposts', 'comments', 'likes'].sort,
    :trial_promoter => ['ordinal_day', 'date_sent', 'day_of_week_sent', 'time_sent', 'platform', 'medium', 'image_used', 'tags', 'link_clicks', 'click_time'].sort,
    :twitter => ['impressions', 'retweets', 'replies', 'likes'].sort
  }
  
  ALLOWED_VALUES = {
    :trial_promoter_day_of_week_sent => ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
    :trial_promoter_platform => ['Twitter', 'Facebook', 'Instagram'],
    :trial_promoter_medium => ['Ad', 'Organic'],
    :trial_promoter_image_used => ['Yes', 'No']
  }
  
  def self.create_data_dictionary(experiment)
    experiment.create_data_dictionary if experiment.data_dictionary.nil?

    DataDictionary::DATA_ELEMENTS.keys.each do |source|
      DataDictionary::DATA_ELEMENTS[source].each do |variable_name|
        experiment.data_dictionary.data_dictionary_entries << DataDictionaryEntry.new(:variable_name => "#{source}_#{variable_name}", :source => source)
      end
    end

    DataDictionary::ALLOWED_VALUES.keys.each do |variable_name|
      entry_with_correct_variable_name = experiment.data_dictionary.data_dictionary_entries.select{ |data_dictionary_entry| data_dictionary_entry.variable_name == variable_name.to_s }[0]
      entry_with_correct_variable_name.allowed_values = DataDictionary::ALLOWED_VALUES[variable_name]
      entry_with_correct_variable_name.save
    end

    experiment.save
  end
end