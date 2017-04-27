# == Schema Information
#
# Table name: clicks
#
#  id                   :integer          not null, primary key
#  click_time           :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  click_meter_event_id :string
#  spider               :boolean
#  unique               :boolean
#

class Click < ActiveRecord::Base
  include HTTParty

  belongs_to :click_meter_tracking_link
  validates :click_meter_tracking_link, presence: true

end
