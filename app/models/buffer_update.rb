# == Schema Information
#
# Table name: buffer_updates
#
#  id                  :integer          not null, primary key
#  buffer_id           :string
#  service_update_id   :string
#  status              :string
#  message_id          :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  sent_from_date_time :datetime
#  published_text      :text
#


class BufferUpdate < ActiveRecord::Base
  extend Enumerize

  validates_presence_of :buffer_id
  enumerize :status, in: [:pending, :sent], default: :pending, predicates: true
  
  belongs_to :message

  before_destroy :delete_buffer_update
  
  def delete_buffer_update
    BufferClient.delete_update(buffer_id)
  end
end
