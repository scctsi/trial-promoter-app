class Website < ActiveRecord::Base
  acts_as_ordered_taggable

  validates :title, presence: true
  validates :url, presence: true

  has_many :messages
  has_and_belongs_to_many :experiments
end
