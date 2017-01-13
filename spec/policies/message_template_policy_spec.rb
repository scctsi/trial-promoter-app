require 'rails_helper'

RSpec.describe MessageTemplatePolicy, type: :policy do
  subject { MessageTemplatePolicy.new(user, message_template, experiment) }

  let(:message_template) { create(:message_template) }
  let(:experiment) { create(:experiment) }

  context "for an initial user" do
    let(:user) { create(:user) }

    it { should_not be_permitted_to(:index) }
    it { should_not be_permitted_to(:new) }
    it { should_not be_permitted_to(:edit) }
    it { should_not be_permitted_to(:show) }
    it { should_not be_permitted_to(:create) }
    it { should_not be_permitted_to(:update) }
    it { should_not be_permitted_to(:import) }
    it { should_not be_permitted_to(:set_message_template) }
  end
end