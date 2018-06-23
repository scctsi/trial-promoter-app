require 'rails_helper'

RSpec.describe HomePolicy, type: :policy do
  subject { HomePolicy.new(user) }

  context "for a user" do
    let(:user) { create(:user) }

    it { should be_permitted_to(:index) }
  end

  context "for an administrator" do
    let(:user) { create(:administrator) }

    it { should be_permitted_to(:index) }
  end
end