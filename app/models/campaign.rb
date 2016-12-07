# == Schema Information
#
# Table name: campaigns
#
#  id         :integer          not null, primary key
#  name       :string(1000)
#  start_date :datetime
#  end_date   :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Campaign < ActiveRecord::Base
  scope :current, -> { where('(start_date is null and end_date is null) or (start_date is not null and start_date <= ?) or (end_date is not null and end_date >= ?)', DateTime.now, DateTime.now) }
  
  validates :name, presence: true
  
  has_one :message_generation_parameter_set, as: :message_generating
  has_many :messages, as: :message_generating
end
