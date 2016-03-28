class Message < ActiveRecord::Base
  extend Enumerize
  
  validates :text, presence: true
  enumerize :status, in: [:new, :sent_to_buffer], default: :new, predicates: true
  
  serialize :buffer_profile_ids
  
  belongs_to :clinical_trial
  belongs_to :message_template
  has_one :buffer_update
  has_many :statistics do 
    def << (value)
      source_statistics_exist = false

      proxy_association.owner.statistics.each do |statistic|
        # There should always be only one set of statistics from a single source.
        # Always overwrite any existing data when the data is for the same source .
        if statistic.source == value.source
          statistic.data = value.data
          source_statistics_exist = true
        end
      end
      
      super value if !source_statistics_exist
    end     
  end  
end
