require 'rails_helper'

RSpec.describe HomePolicy, type: :policy do
  subject { HomePolicy.new(user, experiment, campaign) }

  let(:experiment) { create(:experiment) }
  let(:campaign) { create(:campaign) }

  context "for an initial user" do
    let(:user) { create(:user) }

    it { should_not be_permitted_to(:index) }
  end
end