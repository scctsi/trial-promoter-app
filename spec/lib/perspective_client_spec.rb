require 'rails_helper'
require 'yaml'

RSpec.describe PerspectiveClient do
  before do
    secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
<<<<<<< HEAD
    allow(Setting).to receive(:[]).with(:google_perspective_api_key).and_return(secrets['google_perspective_api_key'])
=======
    allow(Setting).to receive(:[]).with(:google_perspective_api_key).and_return(secrets['google_perspective_access_key'])
>>>>>>> acts-as-codeable
    @text = "This message is stupid."
  end

  describe "(development only tests)", :development_only_tests => true do 
    it 'returns the score from the Google Perspective API' do
      VCR.use_cassette 'perspective_client/calculate_toxicity_score' do
        @toxicity_score = PerspectiveClient.calculate_toxicity_score(@text) 
      end
      expect(@toxicity_score).to eq("0.92")
    end
<<<<<<< HEAD
    
    it 'returns the score from the Google Perspective API when comment has double quotes within the string' do
      VCR.use_cassette 'perspective_client/calculate_toxicity_score_for_double_quotes' do
        @toxicity_score = PerspectiveClient.calculate_toxicity_score("Wow actually touching on the seriousness of the actual addiction!! Not just \"shaming\" yay!") 
      end
      expect(@toxicity_score).to eq("0.31")
    end
=======
>>>>>>> acts-as-codeable
  end
end 
   