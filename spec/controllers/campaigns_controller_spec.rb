require 'rails_helper'

RSpec.describe CampaignsController, type: :controller do
  describe "GET #index" do
    let(:campaigns) { build_pair(:campaign) }
  
    before do
      allow(Campaign).to receive(:all).and_return(campaigns)
      get :index
    end
    
    it 'assigns all existing campaigns to @campaigns' do
      expect(assigns(:campaigns)).to eq(campaigns)
    end
    
    it { should respond_with :ok }
    it { should render_template :index }
  end
  
  # describe "GET #show" do
  #   it "assigns the requested contact to @contact"
  #   it "renders the :show template"
  # end
  
  describe 'GET #new' do
    before do
      get :new
    end
    
    it 'assigns a new Campaign to @campaign' do
      expect(assigns(:campaign)).to be_a_new(Campaign)
    end

    it { should respond_with :ok }
    it { should render_template :new }
  end
  
  # describe "POST #create" do
  #   context "with valid attributes" do
  #     it "saves the new contact in the database"
  #     it "redirects to the home page"
  #   end
    
  #   context "with invalid attributes" do
  #     it "does not save the new contact in the database"
  #     it "re-renders the :new template"
  #   end
  # end
end
