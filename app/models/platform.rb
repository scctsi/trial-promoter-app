class Platform < ActiveRecord::Base
  validates :name, presence: true
  validates :medium, presence: true
end