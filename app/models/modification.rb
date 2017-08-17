# == Schema Information
#
# Table name: modifications
#
#  id            :integer          not null, primary key
#  experiment_id :integer
#  description   :string
#  details       :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Modification < ActiveRecord::Base
  validates :experiment, presence: true

  belongs_to :experiment
end
