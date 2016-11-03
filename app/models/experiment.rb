# == Schema Information
#
# Table name: experiments
#
#  id                              :integer          not null, primary key
#  name                            :string(1000)
#  start_date                      :datetime
#  end_date                        :datetime
#  message_distribution_start_date :datetime
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#

class Experiment < ActiveRecord::Base
  validates :name, presence: true
  
  has_one :message_generation_parameter_set, as: :message_generating
  has_and_belongs_to_many :clinical_trials
end
