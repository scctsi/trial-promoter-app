require 'rails_helper'

RSpec.describe MetricsController, type: :controller do
  describe "GET #index" do
    before do 
      get :index
    end
    
    it { is_expected.to respond_with :ok }
    it { is_expected.to render_with_layout :application }
    it { is_expected.to render_template :index }
  end
end
