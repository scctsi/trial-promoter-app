require 'rails_helper'

RSpec.describe ImagePolicy, type: :policy do
  subject { ImagePolicy.new(user, experiment, image) }

  let(:experiment) { create(:experiment) }
  let(:image) { create(:image) }

  context "for an initial user" do
    let(:user) { create(:user) }

    it { should_not be_permitted_to(:import) }
    it { should_not be_permitted_to(:create) }
  end
end