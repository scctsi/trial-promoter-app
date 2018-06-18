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
      ClickMeterClient.delete_tracking_link(message.message_generating, click_meter_id)
      Kernel.sleep(0.1)
    end
  end

  def get_clicks_by_date(date)
    clicks.select{ |click| (click.click_time.to_date == date.to_date ) && (click.unique == true) && (click.human?)}
  end

  def get_daily_click_totals
    click_totals = []  
    start_date = message.scheduled_date_time 
    3.times do  
      click_totals << self.get_clicks_by_date(start_date).count
      start_date += 1.day 
    end
    return click_totals

  end

  def get_total_clicks
    message = Message.find(self.message_id) 
    experiment_start = DateTime.new(2017,4,19,0,0,0)
    experiment_finish = DateTime.new(2017,7,15,0,0,0)
    total_days_experiment = (experiment_finish.to_i - experiment_start.to_i) / 1.day.seconds
    total_clicks = 0
    total_days_experiment.times do
      total_clicks += (message.click_meter_tracking_link.get_clicks_by_date(experiment_start)).count
      experiment_start += 1.day 
    end 
    return total_clicks
  end
end
