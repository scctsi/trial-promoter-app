require 'rails_helper'

RSpec.describe MessageTemplatePolicy, type: :policy do
  subject { MessageTemplatePolicy.new(user, message_template) }

  let(:message_template) { create(:message_template) }

  context "for an initial user" do
    let(:user) { create(:user) }

    it { should_not be_permitted_to(:index) }
    it { should_not be_permitted_to(:new) }
    it { should_not be_permitted_to(:edit) }
    it { should_not be_permitted_to(:create) }
    it { should_not be_permitted_to(:update) }
    it { should_not be_permitted_to(:import) }
    it { should_not be_permitted_to(:set_message_template) }
  end

  context "for a administrator" do
    let(:user) { create(:administrator) }

    it { should be_permitted_to(:index) }
    it { should be_permitted_to(:new) }
    it { should be_permitted_to(:edit) }
    it { should be_permitted_to(:create) }
    it { should be_permitted_to(:update) }
    it { should be_permitted_to(:import) }
    it { should be_permitted_to(:set_message_template) }
  end

  context "for a statistician" do
    let(:user) { create(:statistician) }

    it { should_not be_permitted_to(:index) }
    it { should_not be_permitted_to(:new) }
    it { should_not be_permitted_to(:edit) }
    it { should_not be_permitted_to(:create) }
    it { should_not be_permitted_to(:update) }
    it { should_not be_permitted_to(:import) }
    it { should_not be_permitted_to(:set_message_template) }
  end

  context "for a read_only" do
    let(:user) { create(:read_only) }

    it { should be_permitted_to(:index) }
    it { should_not be_permitted_to(:new) }
    it { should_not be_permitted_to(:edit) }
    it { should_not be_permitted_to(:create) }
    it { should_not be_permitted_to(:update) }
    it { should_not be_permitted_to(:import) }
    it { should_not be_permitted_to(:set_message_template) }
  end
end