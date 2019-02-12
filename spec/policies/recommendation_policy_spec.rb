require 'rails_helper'

RSpec.describe RecommendationPolicy, type: :policy do
  subject { RecommendationPolicy.new(user, nil) }

  context "for a user with no role" do
    let(:user) { create(:user) }

    it { should_not be_permitted_to(:get) }
  end

  context "for an administrator" do
    let(:user) { create(:administrator) }

    it { should be_permitted_to(:get) }
  end
end