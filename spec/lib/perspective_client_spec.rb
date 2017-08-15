require 'rails_helper'
require 'yaml'

RSpec.describe PerspectiveClient do
  before do
    secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
    allow(Setting).to receive(:[]).with(:google_perspective_api_key).and_return(secrets['google_perspective_access_key'])
    allow(PerspectiveClient).to receive(:post).and_call_original
    @comment = create(:comment)
  end

  describe "(development only tests)", :development_only_tests => true do
    it 'returns the score from the Google Perspective API' do
      VCR.use_cassette 'perspective_client/get_toxicity_score' do
        toxicity_score = PerspectiveClient.get_toxicity_score(@comment.content)
      end
    end
  end
end
