require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  describe 'GET #index' do
    let(:campaigns) { build_pair(:campaign) }
    let(:experiments) { build_pair(:experiment) }
  
    before do
      allow(Campaign).to receive(:all).and_return(campaigns)
      allow(Experiment).to receive(:all).and_return(experiments)
      get :index
    end
    
    it 'assigns all existing campaigns to @campaigns' do
      expect(assigns(:campaigns)).to eq(campaigns)
    end

    it 'assigns all existing experiments to @experiments' do
      expect(assigns(:experiments)).to eq(experiments)
    end
    
    it { is_expected.to respond_with :ok }
    it { is_expected.to render_template :index }
  end
end
