# == Schema Information
#
# Table name: clinical_trials
#
#  id               :integer          not null, primary key
#  title            :string(1000)
#  pi_first_name    :string
#  pi_last_name     :string
#  url              :string(2000)
#  nct_id           :string
#  disease          :string
#  last_promoted_at :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class ClinicalTrial < ActiveRecord::Base
  validates :title, presence: true
  validates :pi_first_name, presence: true
  validates :pi_last_name, presence: true
  validates :url, presence: true
  validates :disease, presence: true
  
  has_many :messages
end
