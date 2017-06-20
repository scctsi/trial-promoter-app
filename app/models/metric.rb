# == Schema Information
#
# Table name: metrics
#
#  id         :integer          not null, primary key
#  source     :string
#  data       :text
#  message_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#



class Metric < ActiveRecord::Base
  extend Enumerize

  serialize :data, Hash

  validates :data, presence: true
  validates :source, presence: true
  enumerize :source, in: [:buffer, :twitter, :facebook, :instagram, :google_analytics], predicates: true

  belongs_to :message
end
