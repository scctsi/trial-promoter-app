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
#  twitter_posting_times           :text
#  facebook_posting_times          :text
#  instagram_posting_times         :text
#  click_meter_group_id            :integer
#  click_meter_domain_id           :integer
#  comment_codes                   :text
#  image_codes                     :text
#  ip_exclusion_list               :text
#

class Experiment < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  include ActiveModel::Validations

  serialize :image_codes, Array
  serialize :comment_codes, Array
  validates_with ExperimentValidator
  validates :name, presence: true
  validates :message_distribution_start_date, presence: true

  has_one :message_generation_parameter_set, as: :message_generating
  has_one :data_dictionary
  has_many :messages, as: :message_generating
  has_many :analytics_files, as: :message_generating
  has_many :modifications
  has_and_belongs_to_many :social_media_profiles

  accepts_nested_attributes_for :message_generation_parameter_set, update_only: true
  
  has_settings :aws, :bitly, :buffer, :click_meter, :dropbox, :facebook, :google, :google_perspective, :twitter

  def set_aws_key(key, secret)
    self.settings(:aws).access_key = key
    self.settings(:aws).secret_access_key = secret
    
    save
  end
  
  def set_facebook_keys(token, ads_token, app_secret)
    self.settings(:facebook).access_token = token
    self.settings(:facebook).ads_access_token = ads_token
    self.settings(:facebook).app_secret = app_secret
    
    save
  end
  
  def set_google_api_key(auth_json_file)
    self.settings(:google).auth_json_file = auth_json_file

    save
  end
  
  def set_twitter_keys(consumer_key, consumer_secret, access_token, access_token_secret)
    self.settings(:twitter).consumer_key = consumer_key
    self.settings(:twitter).consumer_secret = consumer_secret
    self.settings(:twitter).access_token = access_token
    self.settings(:twitter).access_token_secret = access_token_secret
    
    save
  end
  
  def set_api_key(service_name, key)
    self.settings(service_name).api_key = key
    
    save
  end
  
  def to_param
    "#{id}-#{name.parameterize}"
  end
  
  def self.find_by_param(param)
    id = param[0...param.rindex('-')]
    Experiment.find(id)
  end

  def disable_message_generation?
    (self.message_distribution_start_date - Time.now) <= 0
  end
  
  def disable_import?
    messages.count > 0 
  end

  def create_messages
    social_media_profile_picker = SocialMediaProfilePicker.new
    message_factory = MessageFactory.new(social_media_profile_picker)
    message_factory.create(self)
  end

  def each_day
    day = message_distribution_start_date

    while day <= end_date
      yield(day)
      day += 1.day
    end
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
  
  def posting_times
    hash_of_posting_times = {}
    
    {:facebook => facebook_posting_times, :instagram => instagram_posting_times, :twitter => twitter_posting_times}.each do |platform, platform_posting_times|
      array_of_posting_times = []
      
      if !platform_posting_times.blank?
        platform_posting_times.split(',').each do |posting_time|
          parsed_posting_time = {}
          parsed_posting_time[:hour] = posting_time.split(':')[0].to_i
          # Convert to military time
          if !posting_time.index('AM').nil? # AM
            parsed_posting_time[:hour] = 0 if parsed_posting_time[:hour] == 12
          end
          if !posting_time.index('PM').nil? # PM
            parsed_posting_time[:hour] += 12 if parsed_posting_time[:hour] != 12
          end
          parsed_posting_time[:minute] = posting_time.split(':')[1].to_i
          array_of_posting_times << parsed_posting_time
        end
      end
      
      hash_of_posting_times[platform] = array_of_posting_times
    end

    hash_of_posting_times
  end
  
  def timeline
    Timeline.build_default_timeline(self)
  end
  
  def end_date
    message_distribution_start_date + message_generation_parameter_set.length_of_experiment_in_days(MessageTemplate.belonging_to(self).count).days
  end
end
