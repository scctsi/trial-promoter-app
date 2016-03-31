class ClinicalTrial < ActiveRecord::Base
  validates :title, presence: true
  validates :pi_first_name, presence: true
  validates :pi_last_name, presence: true
  validates :url, presence: true
  validates :disease, presence: true
  
  has_many :messages
end
