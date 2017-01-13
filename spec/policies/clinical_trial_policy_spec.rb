require 'rails_helper'

RSpec.describe ClinicalTrialPolicy, type: :policy do
  subject { ClinicalTrialPolicy.new(user, clinical_trial) }

  let(:clinical_trial) { create(:clinical_trial) }

  context "for an initial user" do
    let(:user) { create(:user) }

    it { should_not be_permitted_to(:index) }
    it { should_not be_permitted_to(:show) }
    it { should_not be_permitted_to(:new) }
    it { should_not be_permitted_to(:edit) }
    it { should_not be_permitted_to(:create) }
    it { should_not be_permitted_to(:update) }
    it { should_not be_permitted_to(:set_clinical_trial) }
  end
end