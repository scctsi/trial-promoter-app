class Website < ActiveRecord::Base
  validates :title, presence: true
  validates :url, presence: true

  has_many :messages
  has_and_belongs_to_many :experiments
end
