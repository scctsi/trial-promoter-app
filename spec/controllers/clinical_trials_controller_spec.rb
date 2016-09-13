require 'rails_helper'

RSpec.describe ClinicalTrialsController, type: :controller do
  describe 'GET #index' do
    let(:clinical_trials) { build_pair(:clinical_trial) }
  
    before do
      allow(ClinicalTrial).to receive(:all).and_return(clinical_trials)
      get :index
    end
    
    it 'assigns all existing clinical trials to @clinical_trials' do
      expect(assigns(:clinical_trials)).to eq(clinical_trials)
    end
    
    it { is_expected.to respond_with :ok }
    it { is_expected.to render_template :index }
  end
  
  # describe "GET #show" do
  #   it "assigns the requested contact to @contact"
  #   it "renders the :show template"
  # end
  
  describe 'GET #new' do
    before do
      get :new
      @hashtags = []
      allow(Hashtag).to receive(:all).and_return(@hashtags)
    end
    
    it 'assigns a new clinical trial to @clinical_trial' do
      expect(assigns(:clinical_trial)).to be_a_new(ClinicalTrial)
    end
    
    it 'assigns all hashtags to @hashtags' do
      expect(assigns(:hashtags)).to eq(@hashtags)
    end

    it { is_expected.to respond_with :ok }
    it { is_expected.to render_template :new }
  end
  
  describe 'GET #edit' do
    before do
      @clinical_trial = create(:clinical_trial)
      get :edit, id: @clinical_trial
    end
    
    it 'assigns the requested clinical trial to @clinical_trial' do
      expect(assigns(:clinical_trial)).to eq(@clinical_trial)
    end
    
    it 'renders the edit template' do
      expect(response).to render_template :edit
    end
  end
  
  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new clinical trial' do
        expect {
          post :create, clinical_trial: attributes_for(:clinical_trial)
        }.to change(ClinicalTrial, :count).by(1)
      end
      
      it 'redirects to the index page' do
        post :create, clinical_trial: attributes_for(:clinical_trial)
        expect(response).to redirect_to clinical_trials_url
      end
    end
    
    context 'with invalid attributes' do
      it 'does not save the clinical trial to the database' do
        expect {
          post :create, clinical_trial: attributes_for(:invalid_clinical_trial)
        }.to_not change(ClinicalTrial, :count)
      end
      
      it 're-renders the new template' do
        post :create, clinical_trial: attributes_for(:invalid_clinical_trial)
        expect(response).to render_template :new
      end
    end
  end
  
  describe 'PATCH update' do
    before :each do
      @clinical_trial = create(:clinical_trial)
      patch :update, id: @clinical_trial, clinical_trial: attributes_for(:clinical_trial, pi_first_name: 'New PI first name', pi_last_name: 'New PI last name', title: 'New title', url: 'New URL', disease: 'New disease', hashtags: 'New hashtags')
    end
    
    context 'with valid attributes' do
      it 'locates the requested clinical trial' do
        expect(assigns(:clinical_trial)).to eq(@clinical_trial)
      end
    
      it "changes the clinical trial's attributes" do
        @clinical_trial.reload
        expect(@clinical_trial.pi_first_name).to eq('New PI first name')
        expect(@clinical_trial.pi_last_name).to eq('New PI last name')
        expect(@clinical_trial.title).to eq('New title')
        expect(@clinical_trial.url).to eq('New URL')
        expect(@clinical_trial.disease).to eq('New disease')
        expect(@clinical_trial.hashtags).to eq('New hashtags')
      end
    
      it 'redirects to the index page' do
        expect(response).to redirect_to clinical_trials_url
      end
    end
  end
end
