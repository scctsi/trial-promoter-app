# == Schema Information
#
# Table name: experiments
#
#  id                              :integer          not null, primary key
#  name                            :string(1000)
#  start_date                      :datetime
#  end_date                        :datetime
#  message_distribution_start_date :datetime
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#

class Experiment < ActiveRecord::Base
  validates :name, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true

  # TODO: Small
  has_one :message_generation_parameter_set, as: :message_generating
  has_many :messages, as: :message_generating
  has_and_belongs_to_many :social_media_profiles

  accepts_nested_attributes_for :message_generation_parameter_set, update_only: true

  def to_param
    "#{id}-#{name.parameterize}"
  end

  def disable_message_generation?
    return false if self.message_distribution_start_date.nil?
    (self.message_distribution_start_date - Time.now ) < 1.day
  end

  def create_messages
    tag_matcher = TagMatcher.new
    message_factory = MessageFactory.new(tag_matcher)
    message_factory.create(self)
  end
  
  def each_day
    day = start_date
    
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
          AnalyticsFile.create(:required_upload_date => day, :social_media_profile => profile)
        end
      end
    end
    
    self.analytics_file_todos_created = true
    save
  end
end
