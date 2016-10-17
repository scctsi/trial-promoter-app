# == Schema Information
#
# Table name: buffer_updates
#
#  id                :integer          not null, primary key
#  buffer_id         :string
#  service_update_id :string
#  status            :string
#  message_id        :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class BufferUpdate < ActiveRecord::Base
  extend Enumerize

  validates_presence_of :buffer_id
  enumerize :status, in: [:pending, :sent], default: :pending, predicates: true
  
  belongs_to :message
end
