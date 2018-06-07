# == Schema Information
#
# Table name: messages
#
#  id                           :integer          not null, primary key
#  message_template_id          :integer
#  content                      :text
#  tracking_url                 :string(2000)
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  website_id                   :integer
#  message_generating_id        :integer
#  message_generating_type      :string
#  promotable_id                :integer
#  promotable_type              :string
#  medium                       :string
#  image_present                :string
#  image_id                     :integer
#  publish_status               :string
#  scheduled_date_time          :datetime
#  social_network_id            :string
#  social_media_profile_id      :integer
#  platform                     :string
#  promoted_website_url         :string(2000)
#  campaign_id                  :string
#  backdated                    :boolean
#  original_scheduled_date_time :datetime
#  click_rate                   :float
#  website_goal_rate            :float
#  website_goal_count           :integer
#  website_session_count        :integer
#  impressions_by_day           :text
#  note                         :text
#

class Message < ActiveRecord::Base
  extend Enumerize
  include CampaignId
  acts_as_ordered_taggable_on :experiments

  serialize :impressions_by_day, Hash

  validates :content, presence: true
  validates :platform, presence: true
  validates :promoted_website_url, presence: true
  enumerize :publish_status, in: [:pending, :published_to_buffer, :published_to_social_network], default: :pending, predicates: true
  enumerize :medium, in: [:ad, :organic], default: :organic
  enumerize :platform, in: [:twitter, :facebook, :instagram]
  enumerize :image_present, in: [:with, :without], default: :without

  validates :message_generating, presence: true
  belongs_to :message_generating, polymorphic: true
  belongs_to :message_template
  belongs_to :image
  belongs_to :social_media_profile
  has_one :buffer_update
  has_one :click_meter_tracking_link, dependent: :destroy
  has_many :image_replacements
  has_many :comments
  has_many :metrics do
    def << (value)
      source_metrics_exists = false

      proxy_association.owner.metrics.each do |metric|
        # There should always be only one set of metrics from a single source.
        # Always overwrite any existing data for the same source.
        if metric.source == value.source
          metric.data = value.data
          source_metrics_exists = true
        end
      end

      super value if !source_metrics_exists
    end
  end

  def medium
    return self[:medium].to_sym if !self[:medium].nil?
    nil
  end

  def platform
    return self[:platform].to_sym if !self[:platform].nil?
    nil
  end

  def to_param
    "#{message_generating.to_param}-message-#{id}"
  end

  def self.find_by_param(param)
    id = param[(param.rindex('-') + 1)..-1]
    Message.find(id)
  end

  def visits
    Visit.where(utm_content: self.to_param)
  end

  def scheduled_date_time
    return self[:original_scheduled_date_time] if backdated
    return self[:scheduled_date_time]
  end

  def events
    #REF https://github.com/ankane/ahoy/blob/081d97500f51f20eb2b2ba237ff6f215bbce115c/README.md#querying-properties
    Ahoy::Event.where(name: "Converted").where_properties(utm_content: self.to_param)
  end

  def delayed?
    return scheduled_date_time + 5.minutes < buffer_update.sent_from_date_time
  end

  def backdate(number_of_days)
    # Only backdate twitter ads (we need to allow time for Twitter support to approve the ads)
    return if !(platform == :twitter && medium == :ad)
    # Only backdate once
    return if backdated
    # Only backdate tweets scheduled on May 31st or later
    return if scheduled_date_time.month <= 5 && scheduled_date_time.day <= 30

    self.original_scheduled_date_time = scheduled_date_time
    self.backdated = true
    self.scheduled_date_time -= number_of_days.days
    if !buffer_update.nil?
      buffer_update.destroy
      Throttler.throttle(1)
      self.buffer_update = nil
      self.publish_status = :pending
    end
    save
  end

  def method_missing(name, *args, &block)
    name = name.to_s

    if name.start_with?('metric')
      source = name[7..-1].split('_')[0]
      metric_name = name[7..-1].split('_')[1]
      metrics_from_source = metrics.select{ |metric| metric.source.to_s == source }
      return 'N/A' if metrics_from_source.count == 0
      return 'N/A' if metrics_from_source[0].data[metric_name].nil?
      return metrics_from_source[0].data[metric_name]
    end

    if name.start_with?('percentage')
      source = name[11..-1].split('_')[0]
      metrics_from_source = metrics.select{ |metric| metric.source.to_s == source }
      return 'N/A' if metrics_from_source.count == 0
      metric_1_name = name[11..-1].split('_')[1]
      metric_2_name = name[11..-1].split('_')[2]
      return 'N/A' if metrics_from_source[0].data[metric_1_name].nil? || metrics_from_source[0].data[metric_2_name].nil?
      return 'N/A' if metrics_from_source[0].data[metric_2_name] == 0
      return (metrics_from_source[0].data[metric_1_name].to_f / metrics_from_source[0].data[metric_2_name].to_f) * 100
    end
  end

  def calculate_click_rate
    case platform
    when :facebook
      calculated_rate = percentage_facebook_clicks_impressions
    when :twitter
      calculated_rate = percentage_twitter_clicks_impressions
    when :instagram
      calculated_rate = percentage_instagram_clicks_impressions
    end
    calculated_rate = nil if calculated_rate == 'N/A'
    calculated_rate *= 100 if calculated_rate != nil
    self.click_rate = calculated_rate

    save
  end

  def calculate_website_goal_rate
    calculate_goal_count
    calculate_session_count

    if website_session_count == 0
      self.website_goal_rate = nil
    else
      self.website_goal_rate = (website_goal_count / website_session_count.to_f * 100).round(2)
    end

    save
  end

  def calculate_goal_count(ip_exclusion_list = [])
    goal_count = 0
    # Getting sessions from arbitrary beginning of time to end of time - for entire duration of experiment
    sessions = get_sessions(DateTime.new(1970, 1, 1), DateTime.new(2100, 1, 1), ip_exclusion_list)
    # Converted event is in the Ahoy code.
    # For the TCORS experiment, the 'Converted' event occurs in main.js file of website (Fresh Empire or This Free Life)
    # when user scrolls or clicks on navigation bar
    sessions.each do |session|
      goal_count += 1 if Ahoy::Event.where(visit_id: session.id).where(name: "Converted").count > 0
    end

    self.website_goal_count = goal_count
    save
  end

  def calculate_session_count(ip_exclusion_list = [])
    sessions = get_sessions(DateTime.new(1970, 1, 1), DateTime.new(2100, 1, 1), ip_exclusion_list)
    self.website_session_count = sessions.count

    save
  end

  def self.find_by_alternative_identifier(alternative_identifier_value)
    # When parsing analytics files and other data files, messages need to be found by their
    # social_network_id, campaign_id and sometime the published_text of their buffer_update.
    # This helper method allow a string to be passed in and it searches the above three
    # attributes till it finds a match.
    message = Message.where(:social_network_id => alternative_identifier_value)[0]

    if message.nil?
      message = Message.where(:campaign_id => alternative_identifier_value)[0]
    end

    if message.nil?
      message = Message.joins(:buffer_update).where(:buffer_updates => { :published_text => alternative_identifier_value})[0]
    end

    message
  end

  def get_sessions(start_of_experiment, end_of_experiment, exclude_ip_address_list = [])
    visits = Visit.where(utm_content: self.to_param).to_a
    visits.reject!{ |visit| exclude_ip_address_list.include?(visit.ip) }
    return visits.select{ |session| session.started_at.between?(start_of_experiment, end_of_experiment) }
  end
  
  def get_goal_count(sessions)
    goal_count = 0
    sessions.each do |session|
      goal_count += 1 if Ahoy::Event.where(visit_id: session.id).where(name: "Converted").count > 0
    end
    return goal_count 
  end
  
  def self.find_by_published_text(published_text)
    messages = Message.joins(:buffer_update).where("published_text like ?", published_text.squish)

    raise ActiveRecord::RecordNotUnique, '' if messages.length > 1

    return messages.first
  end
end
