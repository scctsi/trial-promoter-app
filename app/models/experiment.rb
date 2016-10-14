class Experiment < ActiveRecord::Base
  validates :name, presence: true
  
  has_one :message_set_generation_parameter_set
  has_and_belongs_to_many :clinical_trials
end
