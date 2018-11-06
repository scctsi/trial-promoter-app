require 'rails_helper'

RSpec.describe AnalyticsFilePolicy, type: :policy do
  subject { AnalyticsFilePolicy.new(user, analytics_file) }

  let(:analytics_file) { create(:analytics_file) }

  context "for a user with no role" do
    let(:user) { create(:user) }

    it { should_not be_permitted_to(:update) }
    it { should_not be_permitted_to(:process_all_files) }
  end

  context "for an administrator" do
    let(:user) { create(:administrator) }

    it { should be_permitted_to(:update) }
    it { should be_permitted_to(:process_all_files) }
  end
end