class BufferUpdate < ActiveRecord::Base
  extend Enumerize

  validates_presence_of :buffer_id
  enumerize :status, in: [:pending, :sent], default: :pending, predicates: true
  
  belongs_to :message
end
