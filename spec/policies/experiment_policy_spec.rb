require 'rails_helper'

RSpec.describe ExperimentPolicy, type: :policy do
  subject { ExperimentPolicy.new(user, experiment) }

  let(:experiment) { create(:experiment) }

  context "for an initial user" do
    let(:user) { create(:user) }

    it { should_not be_permitted_to(:index) }
    it { should_not be_permitted_to(:show) }
    it { should_not be_permitted_to(:new) }
    it { should_not be_permitted_to(:create) }
    it { should_not be_permitted_to(:edit) }
    it { should_not be_permitted_to(:update) }
    it { should_not be_permitted_to(:create_messages) }
    it { should_not be_permitted_to(:send_to_buffer) }
    it { should_not be_permitted_to(:set_experiment) }
    it { should_not be_permitted_to(:calculate_message_count) }
    it { should_not be_permitted_to(:messages_page) }
  end

  context "for a administrator" do
    let(:user) { create(:administrator) }

    it { should be_permitted_to(:index) }
    it { should be_permitted_to(:new) }
    it { should be_permitted_to(:show) }
    it { should be_permitted_to(:edit) }
    it { should be_permitted_to(:create) }
    it { should be_permitted_to(:update) }
    it { should be_permitted_to(:create_messages) }
    it { should be_permitted_to(:send_to_buffer) }
    it { should be_permitted_to(:set_experiment) }
    it { should be_permitted_to(:calculate_message_count) }
    it { should be_permitted_to(:messages_page) }
  end

  context "for a statistician" do
    let(:user) { create(:statistician) }

    it { should_not be_permitted_to(:index) }
    it { should_not be_permitted_to(:new) }
    it { should be_permitted_to(:show) }
    it { should_not be_permitted_to(:edit) }
    it { should_not be_permitted_to(:create) }
    it { should_not be_permitted_to(:update) }
    it { should_not be_permitted_to(:create_messages) }
    it { should_not be_permitted_to(:send_to_buffer) }
    it { should_not be_permitted_to(:set_experiment) }
    it { should_not be_permitted_to(:calculate_message_count) }
    it { should be_permitted_to(:messages_page) }
  end

  context "for a read_only" do
    let(:user) { create(:read_only) }

    it { should be_permitted_to(:index) }
    it { should_not be_permitted_to(:new) }
    it { should be_permitted_to(:show) }
    it { should_not be_permitted_to(:edit) }
    it { should_not be_permitted_to(:create) }
    it { should_not be_permitted_to(:update) }
    it { should_not be_permitted_to(:create_messages) }
    it { should_not be_permitted_to(:send_to_buffer) }
    it { should_not be_permitted_to(:set_experiment) }
    it { should_not be_permitted_to(:calculate_message_count) }
    it { should be_permitted_to(:messages_page) }
  end
end