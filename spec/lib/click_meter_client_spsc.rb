require 'rails_helper'
require 'yaml'

RSpec.describe BufferClient do
  before do
    secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
    allow(Setting).to receive(:[]).with(:click_meter_api_key).and_return(secrets['click_meter_api_key'])
  end

  describe "(development only tests)", :development_only_tests => true do
  end
end