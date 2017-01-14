# == Schema Information
#
# Table name: messages
#
#  id                          :integer          not null, primary key
#  message_template_id         :integer
#  content                     :text
#  tracking_url                :string(2000)
#  buffer_profile_ids          :text
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  website_id                  :integer
#  message_generating_id       :integer
#  message_generating_type     :string
#  promotable_id               :integer
#  promotable_type             :string
#  medium                      :string
#  image_present               :string
#  image_id                    :integer
#  publish_status              :string
#  buffer_publish_date         :datetime
#  social_network_publish_date :datetime
#  social_network_id           :string
#

class Message < ActiveRecord::Base
  extend Enumerize
  acts_as_ordered_taggable_on :experiments

  validates :content, presence: true
  enumerize :publish_status, in: [:pending, :published_to_buffer, :published_to_social_network], default: :pending, predicates: true
  enumerize :medium, in: [:ad, :organic], default: :organic, predicates: true
  enumerize :image_present, in: [:with, :without], default: :without

  serialize :buffer_profile_ids

  validates :message_generating, presence: true
  belongs_to :message_generating, polymorphic: true
  belongs_to :promotable, polymorphic: true
  belongs_to :message_template
  belongs_to :image
  has_one :buffer_update
  has_many :metrics do
    def << (value)
      source_metrics_exists = false

      proxy_association.owner.metrics.each do |metric|
        # Only allow a metric to be added if the source is same as the message platform (excluding buffer and google_analytics)
        if TrialPromoter.supports?(value.source) && value.source != proxy_association.owner.message_template.platform
          raise InvalidMetricSourceError.new(value.source, proxy_association.owner.message_template.platform)
        end

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

  def self.find_by_service_update_id(service_update_id)
    buffer_updates = BufferUpdate.where(service_update_id: service_update_id)

    return nil if buffer_updates.length == 0
    buffer_updates.first.message
  end
  
  def self.find_by_param(param)
    id = param[(param.rindex('-') + 1)..-1]
    Message.find(id)
  end
  
  def to_param
    "#{message_generating.to_param}-message-#{id}"
  end
end
