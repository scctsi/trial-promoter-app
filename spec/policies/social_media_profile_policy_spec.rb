require 'rails_helper'

RSpec.describe SocialMediaProfilePolicy, type: :policy do
  subject { SocialMediaProfilePolicy.new(user, social_media_profile) }

  let(:social_media_profile) { create(:social_media_profile) }

  context "for an initial user" do
    let(:user) { create(:user) }

    it { should_not be_permitted_to(:sync_with_buffer) }
    it { should_not be_permitted_to(:index) }
    it { should_not be_permitted_to(:edit) }
    it { should_not be_permitted_to(:update) }
  end

  context "for a administrator" do
    let(:user) { create(:administrator) }

    it { should be_permitted_to(:sync_with_buffer) }
    it { should be_permitted_to(:index) }
    it { should be_permitted_to(:edit) }
    it { should be_permitted_to(:update) }
  end
end