# == Schema Information
#
# Table name: messages
#
#  id                  :integer          not null, primary key
#  clinical_trial_id   :integer
#  message_template_id :integer
#  content             :text
#  tracking_url        :string(2000)
#  status              :string
#  buffer_profile_ids  :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class Message < ActiveRecord::Base
  extend Enumerize
  
  validates :content, presence: true
  enumerize :status, in: [:new, :sent_to_buffer], default: :new, predicates: true
  
  serialize :buffer_profile_ids
  
  belongs_to :clinical_trial
  belongs_to :message_template
  has_one :buffer_update
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
  
  def self.find_by_service_update_id(service_update_id)
    buffer_updates = BufferUpdate.where(service_update_id: service_update_id)
    
    return nil if buffer_updates.length == 0
    buffer_updates.first.message
  end
end
