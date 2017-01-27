require 'rails_helper'

RSpec.describe AnalyticsFilePolicy, type: :policy do
  subject { AnalyticsFilePolicy.new(user, analytics_file) }

  let(:analytics_file) { create(:analytics_file) }

  context "for an initial user" do
    let(:user) { create(:user) }

    it { should_not be_permitted_to(:update) }
  end

  context "for a administrator" do
    let(:user) { create(:administrator) }

    it { should be_permitted_to(:update) }
  end

  context "for a statistician" do
    let(:user) { create(:statistician) }

    it { should_not be_permitted_to(:update) }
  end

  context "for a read_only" do
    let(:user) { create(:read_only) }

    it { should_not be_permitted_to(:update) }
  end
end