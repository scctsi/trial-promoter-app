require 'rails_helper'

RSpec.describe MessageTemplatePolicy, type: :policy do
  context "for a user not assigned to an experiment" do
    before do 
      @user = build(:user)
      experiment = build(:experiment)
      @message_template = double("message_template")
      allow(@message_template).to receive(:experiment).and_return(experiment)
    end
    subject { MessageTemplatePolicy.new(@user, @message_template.experiment) }

    it { should_not be_permitted_to(:index) }
    it { should_not be_permitted_to(:new) }
    it { should_not be_permitted_to(:edit) }
    it { should_not be_permitted_to(:create) }
    it { should_not be_permitted_to(:update) }
    it { should_not be_permitted_to(:import) }
    it { should_not be_permitted_to(:set_message_template) }
    it { should_not be_permitted_to(:get_image_selections) }
    it { should_not be_permitted_to(:add_image_to_image_pool) }
    it { should_not be_permitted_to(:remove_image_from_image_pool) }
  end

  context "for a administrator" do
    before(:each) do
      @experiment = build(:experiment) 
      @user = build(:administrator)
    end
    
    subject { MessageTemplatePolicy.new(@user, @experiment) }
    
    it { should be_permitted_to(:index) }
    it { should be_permitted_to(:new) }
    it { should be_permitted_to(:edit) }
    it { should be_permitted_to(:create) }
    it { should be_permitted_to(:update) }
    it { should be_permitted_to(:import) }
    it { should be_permitted_to(:set_message_template) }
    it { should be_permitted_to(:get_image_selections) }
    it { should be_permitted_to(:add_image_to_image_pool) }
    it { should be_permitted_to(:remove_image_from_image_pool) }
  end
end