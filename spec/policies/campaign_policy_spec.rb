require 'rails_helper'

RSpec.describe CampaignPolicy, type: :policy do
  subject { CampaignPolicy.new(user, campaign) }

  let(:campaign) { create(:campaign) }

  context "for an initial user" do
    let(:user) { create(:user) }

    it { should_not be_permitted_to(:index) }
    it { should_not be_permitted_to(:new) }
    it { should_not be_permitted_to(:show) }
    it { should_not be_permitted_to(:edit) }
    it { should_not be_permitted_to(:create) }
    it { should_not be_permitted_to(:update) }
    it { should_not be_permitted_to(:set_campaign) }
  end
end