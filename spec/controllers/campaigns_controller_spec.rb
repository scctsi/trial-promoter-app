require 'rails_helper'

RSpec.describe CampaignsController, type: :controller do
  describe 'GET #index' do
    let(:campaigns) { build_pair(:campaign) }
  
    before do
      allow(Campaign).to receive(:all).and_return(campaigns)
      get :index
    end
    
    it 'assigns all existing campaigns to @campaigns' do
      expect(assigns(:campaigns)).to eq(campaigns)
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
    end
    
    it 'assigns a new campaign to @campaign' do
      expect(assigns(:campaign)).to be_a_new(Campaign)
    end

    it { is_expected.to respond_with :ok }
    it { is_expected.to render_template :new }
  end
  
  describe 'GET #edit' do
    before do
      @campaign = create(:campaign)
      get :edit, id: @campaign
    end
    
    it 'assigns the requested campaign to @campaign' do
      expect(assigns(:campaign)).to eq(@campaign)
    end
    
    it 'renders the edit template' do
      expect(response).to render_template :edit
    end
  end
  
  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new campaign' do
        expect {
          post :create, campaign: attributes_for(:campaign)
        }.to change(Campaign, :count).by(1)
      end
      
      it 'redirects to the home page' do
        post :create, campaign: attributes_for(:campaign)
        expect(response).to redirect_to root_url
      end
    end
    
    context 'with invalid attributes' do
      it 'does not save the campaign to the database' do
        expect {
          post :create, campaign: attributes_for(:invalid_campaign)
        }.to_not change(Campaign, :count)
      end
      
      it 're-renders the new template' do
        post :create, campaign: attributes_for(:invalid_campaign)
        expect(response).to render_template :new
      end
    end
  end
  
  describe 'PATCH update' do
    before :each do
      @campaign = create(:campaign)
      @clinical_trials = create_pair(:clinical_trial)
      patch :update, id: @campaign, campaign: attributes_for(:campaign, name: 'New name', start_date: Time.local(2000, 1, 1, 9, 0, 0), end_date: Time.local(2000, 2, 1, 9, 0, 0), clinical_trial_ids: [@clinical_trials[0].id, @clinical_trials[1].id])
    end
    
    context 'with valid attributes' do
      it 'locates the requested campaign' do
        expect(assigns(:campaign)).to eq(@campaign)
      end
    
      it "changes the campaign's attributes" do
        @campaign.reload
        expect(@campaign.name).to eq('New name')
        expect(@campaign.start_date).to eq(Time.local(2000, 1, 1, 9, 0, 0))
        expect(@campaign.end_date).to eq(Time.local(2000, 2, 1, 9, 0, 0))
        expect(@campaign.clinical_trials).to include(@clinical_trials[0])
        expect(@campaign.clinical_trials).to include(@clinical_trials[1])
      end
    
      it 'redirects to the home page' do
        expect(response).to redirect_to root_url
      end
    end
  end
end
