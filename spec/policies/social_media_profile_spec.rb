require 'rails_helper'

RSpec.describe SocialMediaProfilePolicy, type: :policy do
  subject { SocialMediaProfilePolicy.new(user, social_media_profile) }

  let(:social_media_profile) { create(:social_media_profile) }

  context "for an initial user" do
    let(:user) { create(:user) }

    it { should_not be_permitted_to(:sync_with_buffer) }
  end
end