class Statistic < ActiveRecord::Base
  extend Enumerize
  
  serialize :data

  validates :data, presence: true
  validates :source, presence: true
  enumerize :source, in: [:buffer, :twitter, :facebook], predicates: true
  
  belongs_to :message
end
