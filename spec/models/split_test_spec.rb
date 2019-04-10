require 'rails_helper'

RSpec.describe SplitTest, type: :model do
  it { is_expected.to belong_to(:experiment) }
  it { is_expected.to validate_presence_of(:experiment) }
  it { is_expected.to belong_to(:variation_a) }
  it { is_expected.to validate_presence_of(:variation_a) }
  it { is_expected.to belong_to(:variation_b) }
  it { is_expected.to validate_presence_of(:variation_b) }
  it { is_expected.to have_many(:results) }
  
  describe 'updating split tests for an experiment' do
    before do
      @experiment = create(:experiment)
      post_template = create(:post_template, experiment: @experiment)
      @posts = create_list(:post, 5, experiment: @experiment, post_template: post_template)
    end
    
    it 'creates a new split test using the first two posts (chronological order of creation) as variations to be tested if no split tests exist' do
      SplitTest.update_split_tests(@experiment)
      
      @experiment.reload
      expect(@experiment.split_tests.count).to eq(1)
      expect(@experiment.split_tests[0].variation_a).to eq(@posts[0])
      expect(@experiment.split_tests[0].variation_b).to eq(@posts[1])
    end
  end
end