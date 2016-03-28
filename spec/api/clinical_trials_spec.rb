require 'rails_helper'

describe "Clinical Trials API" do
  before do
    @created_clinical_trials = create_list(:clinical_trial, 5)
  end
  
	it "returns a list of clinical trials with proper data types" do
		get "/api/v1/clinical_trials"
		expect(response).to be_success
		# expect_json_types('events.*', {id: :integer, title: :string, pi_first_name: :string, pi_last_name: :string})
		# expect_json("events.0",{:id => 1,:title => "SpriteXchange Nov Event"})
		# expect_json_keys('events.0', [:id, :title])
	end
end