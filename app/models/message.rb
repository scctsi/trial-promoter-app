# == Schema Information
#
# Table name: messages
#
#  id                      :integer          not null, primary key
#  message_template_id     :integer
#  content                 :text
#  tracking_url            :string(2000)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  website_id              :integer
#  message_generating_id   :integer
#  message_generating_type :string
#  promotable_id           :integer
#  promotable_type         :string
#  medium                  :string
#  image_present           :string
#  image_id                :integer
#  publish_status          :string
#  scheduled_date_time     :datetime
#  social_network_id       :string
#  social_media_profile_id :integer
#  platform                :string
#  promoted_website_url    :string(2000)
#

class Message < ActiveRecord::Base
  extend Enumerize
  acts_as_ordered_taggable_on :experiments

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
    
    self.backdated = true
    self.original_scheduled_date_time = scheduled_date_time
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
      return (metrics_from_source[0].data[metric_1_name].to_f / metrics_from_source[0].data[metric_2_name].to_f) * 100
    end
  end
end
