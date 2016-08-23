class Hashtag < ActiveRecord::Base
  validates :phrase, presence: true
  validates :phrase, uniqueness: true
end
