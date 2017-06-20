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
  has_many :clicks, dependent: :destroy

  before_destroy :delete_click_meter_tracking_link

  def delete_click_meter_tracking_link
    if !Rails.env.test?
      ClickMeterClient.delete_tracking_link(click_meter_id)
      Kernel.sleep(0.1)
    end
  end

  def get_clicks_by_date(requested_date)
    clicks = Click.where(click_meter_tracking_link_id: self)
    clicks.select{ |click| (click.click_time.to_date == (requested_date).to_date) }
  end
end
