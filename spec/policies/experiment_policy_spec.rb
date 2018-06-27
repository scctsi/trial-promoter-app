require 'rails_helper'

RSpec.describe ExperimentPolicy, type: :policy do
  context "for a user not assigned to an experiment" do
    before(:each) do
      @experiment = create(:experiment) 
      @user = create(:user)
    end
    subject { ExperimentPolicy.new(@user, @experiment) }

    it { should be_permitted_to(:index) }
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
    
    it 'returns experiments for this scope' do
      experiments = ExperimentPolicy::Scope.new(@user, Experiment).resolve
  
      expect(experiments.count).to eq(0)
    end
  end

  context "for a administrator" do
    before(:each) do
      @experiment = create(:experiment) 
      @user = create(:administrator)
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
        
    it 'returns experiments for this scope' do
      experiments = ExperimentPolicy::Scope.new(@user, Experiment).resolve
  
      expect(experiments.count).to eq(1)
      expect(experiments[0]).to eq(@experiment)
    end
  end

  context "for a user assigned to the experiment" do
    before(:each) do
      @experiments = create_pair(:experiment) 
      @user = create(:user)
      @experiments[0].users << @user
      @experiments[0].save
    end
    subject { ExperimentPolicy.new(@user, @experiments[0]) }

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
        
    # context 'current user is associated with experiments' do
    it 'returns experiments for this scope' do
      experiments = ExperimentPolicy::Scope.new(@user, Experiment).resolve
  
      expect(experiments.count).to eq(1)
      expect(experiments[0]).to eq(@experiments[0])
    end
  end
end