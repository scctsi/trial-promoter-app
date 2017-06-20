# == Schema Information
#
# Table name: clicks
#
#  id                           :integer          not null, primary key
#  click_time                   :datetime
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  click_meter_event_id         :string
#  spider                       :boolean
#  unique                       :boolean
#  click_meter_tracking_link_id :integer
#


require 'rails_helper'
require 'yaml'

RSpec.describe Click do
  it { is_expected.to validate_presence_of :click_meter_tracking_link }
  it { is_expected.to belong_to :click_meter_tracking_link }

  it 'determines if click was a unique spider visit' do
    unique_spider_click = Click.new(spider: '1', unique: '1')

    expect(unique_spider_click.human?).to be false
  end
    
  it 'determines if click was a unique human visit' do
    unique_human_click = Click.new(spider: '0', unique: '1')

    expect(unique_human_click.human?).to be true
  end

  it 'determines if click was a returning human visit' do
    returning_human_click = Click.new(spider: '0', unique: '0')
    
    expect(returning_human_click.human?).to be true
  end

  it 'determines if click was a returning spider' do  
    returning_spider_click = Click.new(spider: '1', unique: '0')
    
    expect(returning_spider_click.human?).to be false
  end
end
 
