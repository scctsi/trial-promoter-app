require 'rails_helper'

RSpec.describe AdPolicy, type: :policy do
  subject { AdPolicy.new(user, nil) }

  context "for a user with no role" do
    let(:user) { create(:user) }

    it { should_not be_permitted_to(:previews) }
    it { should_not be_permitted_to(:specifications) }
  end

  context "for an administrator" do
    let(:user) { create(:administrator) }

    it { should be_permitted_to(:previews) }
    it { should be_permitted_to(:specifications) }
  end
end