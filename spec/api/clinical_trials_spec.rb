require 'rails_helper'

describe "Clinical Trials API" do
  describe "get /api/v1/clinical_trials" do
    before do
      @created_clinical_trials = create_list(:clinical_trial, 5)
      get "/api/v1/clinical_trials"
    end

    it "is successful" do
  		expect(response).to be_success
    end
    
    it "returns all attributes for each clinical trial" do
      expect_json_keys("clinical_trials.*", [:id, :title, :pi_first_name, :pi_last_name, :url, :nct_id, :disease])
    end
    
    it 'returns the correct JSON data types for all attributes' do
      expect_json_types("clinical_trials.*", {id: :integer, title: :string, pi_first_name: :string, pi_last_name: :string, url: :string, disease: :string, nct_id: :string_or_null})
    end
    
    it 'returns all created clinical trials' do
      expect_json_sizes("clinical_trials", @created_clinical_trials.length);
    end
    
    it 'returns the correct values for all the attributes of a clinical trial' do
      expect_json("clinical_trials.0", 
                  id: @created_clinical_trials[0][:id],
                  title: @created_clinical_trials[0][:title],
                  pi_first_name: @created_clinical_trials[0][:pi_first_name],
                  pi_last_name: @created_clinical_trials[0][:pi_last_name],
                  url: @created_clinical_trials[0][:url],
                  disease: @created_clinical_trials[0][:disease],
                  nct_id: @created_clinical_trials[0][:nct_id])
    end
  end
  
  describe "post /api/v1/clinical_trials/" do
    before do
      @body = {:title => "Title", :pi_first_name => "John", :pi_last_name => "Doe", :url => "http://www.clinicaltrial.com/", :disease => "Cancer"}
      post "/api/v1/clinical_trials", @body 
    end

    it "is successful" do
  		expect(response).to be_success
    end
    
    it "returns the id attribute of the newly created clinical trial" do
      expect_json_keys([:id])
    end
    
    it 'returns the correct JSON data type for the id attribute' do
      expect_json_types({id: :integer})
    end
    
    it 'successfully creates a new clinical trial' do
      clinical_trial = ClinicalTrial.first
      
      expect_json(id: clinical_trial.id)
      expect(clinical_trial.title).to eq(@body[:title])
      expect(clinical_trial.pi_first_name).to eq(@body[:pi_first_name])
      expect(clinical_trial.pi_last_name).to eq(@body[:pi_last_name])
      expect(clinical_trial.url).to eq(@body[:url])
      expect(clinical_trial.disease).to eq(@body[:disease])
      expect(clinical_trial.nct_id).to eq(@body[:nct_id])
    end
  end
end