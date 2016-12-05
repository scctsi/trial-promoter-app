# == Schema Information
#
# Table name: websites
#
#  id         :integer          not null, primary key
#  name       :string(1000)
#  url        :string(2000)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Website < ActiveRecord::Base
  acts_as_ordered_taggable
  acts_as_ordered_taggable_on :experiments

  validates :url, presence: true

  has_many :messages
end
