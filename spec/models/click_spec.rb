# == Schema Information
#
# Table name: clicks
#
#  id                   :integer          not null, primary key
#  click_time           :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  click_meter_event_id :string
#  Spider               :boolean
#  Unique               :boolean
#

require 'rails_helper'
require 'yaml'

RSpec.describe Click do
  before do
    secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
    allow(Setting).to receive(:[]).with(:click_meter_api_key).and_return(secrets['click_meter_api_key'])
  end
end
