require 'rails_helper'

RSpec.describe MessagePolicy, type: :policy do
  subject { MessagePolicy.new(user, message) }

  let(:message) { build(:message) }

  context "for an initial user" do
    let(:user) { create(:user) }

    it { should_not be_permitted_to(:edit_campaign_id) }
    it { should_not be_permitted_to(:new_campaign_id) }
    it { should_not be_permitted_to(:edit_note) }
    it { should_not be_permitted_to(:new_note) }
  end

  context "for a administrator" do
    let(:user) { create(:administrator) }

    it { should be_permitted_to(:edit_campaign_id) }
    it { should be_permitted_to(:new_campaign_id) }
    it { should be_permitted_to(:edit_note) }
    it { should be_permitted_to(:new_note) }
  end

  context "for a statistician" do
    let(:user) { create(:statistician) }

    it { should_not be_permitted_to(:edit_campaign_id) }
    it { should_not be_permitted_to(:new_campaign_id) }
    it { should_not be_permitted_to(:edit_note) }
    it { should_not be_permitted_to(:new_note) }
  end

  context "for a read_only" do
    let(:user) { create(:read_only) }

    it { should_not be_permitted_to(:edit_campaign_id) }
    it { should_not be_permitted_to(:new_campaign_id) }
    it { should_not be_permitted_to(:edit_note) }
    it { should_not be_permitted_to(:new_note) }
  end
end