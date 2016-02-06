class MessageTemplate < ActiveRecord::Base
  validates :content, presence: true
  validates :platform, presence: true
end
