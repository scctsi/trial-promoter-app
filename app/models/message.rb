class Message < ActiveRecord::Base
  validates :content, presence: true
  
  belongs_to :clinical_trial
  belongs_to :message_template
end
