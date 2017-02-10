# == Schema Information
#
# Table name: posting_times
#
#  id            :integer          not null, primary key
#  experiment_id :integer
#  posting_times :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class PostingTime < ActiveRecord::Base
  belongs_to :experiment
  serialize :posting_times

  validates :experiment, presence: true
end
