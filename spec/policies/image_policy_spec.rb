require 'rails_helper'

RSpec.describe ImagePolicy, type: :policy do
  subject { ImagePolicy.new(user, image) }

  let(:image) { create(:image) }

  context "for an initial user" do
    let(:user) { create(:user) }

    it { should_not be_permitted_to(:import) }
    it { should_not be_permitted_to(:create) }
  end

  context "for a administrator" do
    let(:user) { create(:administrator) }

    it { should be_permitted_to(:import) }
    it { should be_permitted_to(:create) }
  end

  context "for a statistician" do
    let(:user) { create(:statistician) }

    it { should_not be_permitted_to(:import) }
    it { should_not be_permitted_to(:create) }
  end

  context "for a read_only" do
    let(:user) { create(:read_only) }

    it { should_not be_permitted_to(:import) }
    it { should_not be_permitted_to(:create) }
  end
end