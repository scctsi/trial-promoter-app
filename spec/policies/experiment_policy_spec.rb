require 'rails_helper'

RSpec.describe ExperimentPolicy, type: :policy do
  context "for a user not assigned to an experiment" do
    before(:each) do
      @experiment = build(:experiment) 
      @user = build(:user)
    end
    subject { ExperimentPolicy.new(@user, @experiment) }

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
    it { should_not be_permitted_to(:comments_page) }
  end

  context "for a administrator" do
    before(:each) do
      @experiment = build(:experiment) 
      @user = build(:administrator)
    end
    subject { ExperimentPolicy.new(@user, @experiment) }

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
    it { should be_permitted_to(:comments_page) }
    end

  context "for a user assigned to the experiment" do
    before(:each) do
      @experiment = build(:experiment) 
      @user = build(:user)
      @experiment.users << @user
    end
    subject { ExperimentPolicy.new(@user, @experiment) }

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
    it { should be_permitted_to(:comments_page) }
  end
end