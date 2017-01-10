require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  before do
    sign_in create(:user)
  end

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

    it 'redirects unauthenticated user to sign-in page' do
      sign_out(:user)

      get :index

      expect(response).to redirect_to :new_user_session
    end
  end
end
