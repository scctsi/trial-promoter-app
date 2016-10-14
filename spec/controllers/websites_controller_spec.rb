require 'rails_helper'

RSpec.describe WebsitesController, type: :controller do
  describe 'GET #index' do
    let(:websites) { build_pair(:website) }
  
    before do
      allow(Website).to receive(:all).and_return(websites)
      get :index
    end
    
    it 'assigns all existing websites to @websites' do
      expect(assigns(:websites)).to eq(websites)
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
    
    it 'assigns a new website to @website' do
      expect(assigns(:website)).to be_a_new(Website)
    end
    
    it { is_expected.to respond_with :ok }
    it { is_expected.to render_template :new }
  end
  
  describe 'GET #edit' do
    before do
      @website = create(:website)
      get :edit, id: @website
    end
    
    it 'assigns the requested website to @website' do
      expect(assigns(:website)).to eq(@website)
    end
    
    it 'renders the edit template' do
      expect(response).to render_template :edit
    end
  end
  
  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new website' do
        expect {
          post :create, website: attributes_for(:website)
        }.to change(Website, :count).by(1)
      end
      
      it 'redirects to the index page' do
        post :create, website: attributes_for(:website)
        expect(response).to redirect_to websites_url
      end
    end
    
    context 'with invalid attributes' do
      it 'does not save the website to the database' do
        expect {
          post :create, website: attributes_for(:invalid_website)
        }.to_not change(Website, :count)
      end
      
      it 're-renders the new template' do
        post :create, website: attributes_for(:invalid_website)
        expect(response).to render_template :new
      end
    end
  end
  
  describe 'PATCH update' do
    before :each do
      @website = create(:website)
      patch :update, id: @website, website: attributes_for(:website, title: 'New title', url: 'New URL')
    end
    
    context 'with valid attributes' do
      it 'locates the requested website' do
        expect(assigns(:website)).to eq(@website)
      end
    
      it "changes the website's attributes" do
        @website.reload
        expect(@website.title).to eq('New title')
        expect(@website.url).to eq('New URL')
      end
    
      it 'redirects to the index page' do
        expect(response).to redirect_to websites_url
      end
    end
  end
end
