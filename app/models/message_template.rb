class MessageTemplate < ActiveRecord::Base
  serialize :content

  validates :initial_id, presence: true
  validates :content, presence: true
  validates :platform, presence: true
  validates :message_type, presence: true

  has_many :messages
end