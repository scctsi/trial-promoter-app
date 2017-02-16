# == Schema Information
#
# Table name: experiments
#
#  id                              :integer          not null, primary key
#  name                            :string(1000)
#  end_date                        :datetime
#  message_distribution_start_date :datetime
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  analytics_file_todos_created    :boolean
#  posting_times                   :text
#

class Experiment < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  include ActiveModel::Validations

  validates_with ExperimentValidator
  validates :name, presence: true
  validates :end_date, presence: true
  validates :message_distribution_start_date, presence: true

  has_one :message_generation_parameter_set, as: :message_generating
  has_one :data_dictionary
  has_many :messages, as: :message_generating
  has_many :analytics_files, as: :message_generating
  has_and_belongs_to_many :social_media_profiles

  accepts_nested_attributes_for :message_generation_parameter_set, update_only: true

  def to_param
    "#{id}-#{name.parameterize}"
  end

  def disable_message_generation?
    return false if message_distribution_start_date.nil?
    (self.message_distribution_start_date - Time.now ) < 3.days
  end

  def create_messages
    tag_matcher = TagMatcher.new
    social_media_profile_picker = SocialMediaProfilePicker.new
    message_factory = MessageFactory.new(tag_matcher, social_media_profile_picker)
    message_factory.create(self)
  end

  def each_day
    day = message_distribution_start_date

    while day <= end_date
      yield(day)
      day += 1.day
    end
  end

  def social_media_profiles_needing_analytics_uploads
    social_media_profiles.select { |social_media_profile| social_media_profile.platform == :twitter }
  end

  def create_analytics_file_todos
    profiles = social_media_profiles_needing_analytics_uploads
    if profiles.count > 0
      each_day do |day|
        profiles.each do |profile|
          AnalyticsFile.create(:required_upload_date => day, :social_media_profile => profile, :message_generating => self)
        end
      end
    end

    self.analytics_file_todos_created = true
    save
  end

  def self.allowed_times
    allowed_times = []

    (1..12).each do |hour|
      (0..5).each do |tens_digit_minute|
        (0..9).each do |ones_digit_minute|
          allowed_times << "#{hour}:#{tens_digit_minute}#{ones_digit_minute} AM"
          allowed_times << "#{hour}:#{tens_digit_minute}#{ones_digit_minute} PM"
        end
      end
    end

    allowed_times
  end
  
  def posting_times_as_datetimes
    return [] if posting_times.nil?

    array_of_posting_times = []

    array_of_posting_times = posting_times.split(',')
    array_of_posting_times.map! { |posting_time| DateTime.parse(posting_time, DateTime.new(2000, 1, 1)) }
    
    array_of_posting_times
  end
  
  def timeline
    Timeline.build_default_timeline(self)
  end
end
