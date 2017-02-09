require 'rails_helper'

RSpec.describe DataDictionaryPolicy, type: :policy do
  subject { DataDictionaryPolicy.new(user, data_dictionary) }

  let(:data_dictionary) { create(:data_dictionary) }

  context "for an initial user" do
    let(:user) { create(:user) }

    it { should_not be_permitted_to(:show) }
  end

  context "for a administrator" do
    let(:user) { create(:administrator) }

    it { should be_permitted_to(:show) }
  end

  context "for a statistician" do
    let(:user) { create(:statistician) }

    it { should be_permitted_to(:show) }
  end

  context "for a read_only" do
    let(:user) { create(:read_only) }

    it { should be_permitted_to(:show) }
  end
end