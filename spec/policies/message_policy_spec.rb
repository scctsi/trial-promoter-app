require 'rails_helper'

RSpec.describe MessagePolicy, type: :policy do
  subject { MessagePolicy.new(user, message) }

  let(:message) { build(:message) }

  context "for a user with no role" do
    let(:user) { create(:user) }

    it { should_not be_permitted_to(:edit_campaign_id) }
    it { should_not be_permitted_to(:new_campaign_id) }
    it { should_not be_permitted_to(:edit_note) }
    it { should_not be_permitted_to(:new_note) }
  end

  context "for an administrator" do
    let(:user) { create(:administrator) }

    it { should be_permitted_to(:edit_campaign_id) }
    it { should be_permitted_to(:new_campaign_id) }
    it { should be_permitted_to(:edit_note) }
    it { should be_permitted_to(:new_note) }
  end
end