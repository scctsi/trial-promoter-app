class ClickMeterTrackingLink < ActiveRecord::Base
  belongs_to :message
  validates :message, presence: true
end
