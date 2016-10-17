# == Schema Information
#
# Table name: websites
#
#  id         :integer          not null, primary key
#  title      :string(1000)
#  url        :string(2000)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Website < ActiveRecord::Base
  acts_as_ordered_taggable

  validates :title, presence: true
  validates :url, presence: true

  has_many :messages
  has_and_belongs_to_many :experiments
end
