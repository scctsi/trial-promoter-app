require 'rails_helper'

describe "Clinical Trials API" do
  before do
    @created_clinical_trials = create_list(:clinical_trial, 5)
  end
  
  describe "get /api/v1/clinical_trials" do
    before do
      get "/api/v1/clinical_trials"
    end

    it "is successful" do
  		expect(response).to be_success
    end
    
    it "returns the correct json data types" do
  		expect_json_types(id: :integer, title: :string, pi_first_name: :string, pi_last_name: :string, url: :string, nct_id: :string, disease: :string, created_at: :date, updated_at: :date)
    end
  end
  
	it "returns a list of clinical trials with proper data types" do
		# expect_json("events.0",{:id => 1,:title => "SpriteXchange Nov Event"})
		# expect_json_keys('events.0', [:id, :title])
	end
end