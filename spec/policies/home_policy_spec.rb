require 'rails_helper'

RSpec.describe HomePolicy, type: :policy do
  subject { HomePolicy.new(user) }

  context "for a user not associated with the experiment" do
    let(:user) { create(:user) }

    it { should_not be_permitted_to(:index) }
  end

  context "for a user associated with the experiment" do
    let(:user) { create(:administrator) }

    it { should be_permitted_to(:index) }
  end

  # context "for a statistician" do
  #   let(:user) { create(:statistician) }

  #   it { should be_permitted_to(:index) }
  # end

  # context "for a read_only" do
  #   let(:user) { create(:read_only) }

  #   it { should be_permitted_to(:index) }
  # end
end