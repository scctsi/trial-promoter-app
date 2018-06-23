require 'rails_helper'

RSpec.describe DataDictionaryPolicy, type: :policy do
  before(:each) do
    @experiment = create(:experiment) 
    @users = create_pair(:user)
    @experiment.users << @users[0]
    @experiment.save
    @data_dictionary = create(:data_dictionary)
  end
  
  context "for a user not assigned to an experiment" do
    subject { DataDictionaryPolicy.new(@users[1], @experiment) }

    it { should_not be_permitted_to(:show) }
    it { should_not be_permitted_to(:edit) }
    it { should_not be_permitted_to(:update) }
  end
  
  context "for a user assigned to an experiment" do
    subject { DataDictionaryPolicy.new(@users[0], @experiment) }

    it { should be_permitted_to(:show) }
    it { should be_permitted_to(:edit) }
    it { should be_permitted_to(:update) }
  end

  context "for a administrator" do
    let(:user) { create(:administrator) }
    subject { DataDictionaryPolicy.new(user, @experiment) }

    it { should be_permitted_to(:show) }
    it { should be_permitted_to(:edit) }
    it { should be_permitted_to(:update) }
  end
end