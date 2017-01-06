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
  
  def self.parse_ga_data(ga_data)
    column_headers = ga_data.column_headers
    rows = ga_data.rows

    # TODO: This method really doesn't belong to the Message model; implement a Parser class once we get more sources of metrics
    # This method parses the ga_data (returned by google-api-ruby-client) into a { message_param: { metric_1_name: metric_1_value } } hash
    # Step 1: Determine which column contains the ga:adContent dimension (The ga:adContent dimension should contain the to_param value of a message, which should be unique within any given installation of Trial Promoter.)
    ad_content_column_index = column_headers.index{ |column_header| column_header.name == 'ga:adContent' }
    raise MissingAdContentDimensionError if ad_content_column_index.nil?
    # Step 2: Get the metric column names
    metric_column_names = column_headers.select{ |column_header| column_header.column_type == 'METRIC' }.map(&:name)
    # Step 3: Get the indices (zero-based) of the metric columns 
    metric_column_indices = column_headers.each_index.select{|column_header| column_headers[column_header].column_type == 'METRIC'}
    # Step 4: Construct the parsed hash
    parsed_data = {}
    rows.each do |ga_data_row|
      metric_hash = {}
      metric_column_names.each.with_index do |metric_column_name, index|
        metric_hash[metric_column_name] = ga_data_row[metric_column_indices[index]].to_i
      end
      parsed_data[ga_data_row[ad_content_column_index]] = metric_hash
    end
    
    parsed_data
  end
  
  def self.update_ga_metrics(ga_metrics)
    ga_metrics.each do |key, value|
      message = Message.find_by_param(key)
      message.metrics << Metric.new(source: :google_analytics, data: value)
      message.save
    end
  end
end
