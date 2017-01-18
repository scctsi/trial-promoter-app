require 'rails_helper'

RSpec.describe SettingPolicy, type: :policy do
  subject { SettingPolicy.new(user, social_media_profile) }

  let(:social_media_profile) { create(:social_media_profile) }

  context "for an initial user" do
    let(:user) { create(:user) }

    it { should_not be_permitted_to(:index) }
    it { should_not be_permitted_to(:edit) }
    it { should_not be_permitted_to(:update) }
    it { should_not be_permitted_to(:get_setting) }
  end

  context "for a administrator" do
    let(:user) { create(:administrator) }

    it { should be_permitted_to(:index) }
    it { should be_permitted_to(:edit) }
    it { should be_permitted_to(:update) }
    it { should be_permitted_to(:get_setting) }
  end

  context "for a statistician" do
    let(:user) { create(:statistician) }

    it { should_not be_permitted_to(:index) }
    it { should_not be_permitted_to(:edit) }
    it { should_not be_permitted_to(:update) }
    it { should_not be_permitted_to(:get_setting) }
  end

  context "for a read_only" do
    let(:user) { create(:read_only) }

    it { should_not be_permitted_to(:index) }
    it { should_not be_permitted_to(:edit) }
    it { should_not be_permitted_to(:update) }
    it { should_not be_permitted_to(:get_setting) }
  end
end