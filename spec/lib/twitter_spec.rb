require 'rails_helper'
require 'yaml'

RSpec.describe Twitter do
  before do
    secrets = YAML.load_file("#{Rails.root}/spec/support/secrets.yml")
    allow(Setting).to receive(:[]).with(:twitter_consumer_key).and_return(secrets['twitter']['consumer_key'])
    allow(Setting).to receive(:[]).with(:twitter_consumer_secret).and_return(secrets['twitter']['consumer_secret'])
    allow(Setting).to receive(:[]).with(:twitter_access_token).and_return(secrets['twitter']['access_token'])
    allow(Setting).to receive(:[]).with(:twitter_access_token_secret).and_return(secrets['twitter']['access_token_secret'])
  end
  
  describe "(development only tests)", :development_only_tests => true do
    
  end
end