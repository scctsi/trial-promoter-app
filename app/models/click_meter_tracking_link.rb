# == Schema Information
#
# Table name: click_meter_tracking_links
#
#  id              :integer          not null, primary key
#  click_meter_id  :string
#  click_meter_uri :string(2000)
#  tracking_url    :string(2000)
#  destination_url :string(2000)
#  message_id      :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class ClickMeterTrackingLink < ActiveRecord::Base
  belongs_to :message
  validates :message, presence: true
  
  before_destroy :delete_click_meter_tracking_link
  
  def delete_click_meter_tracking_link
    if Rails.env.production?
      ClickMeterClient.delete_tracking_link(click_meter_id)
      Kernel.sleep(0.1) 
    end
  end
end
