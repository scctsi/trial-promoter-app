require 'rails_helper'

describe Post do
  it { is_expected.to belong_to :post_template }
  it { is_expected.to validate_presence_of(:post_template) }
  it { is_expected.to belong_to(:experiment) }
  it { is_expected.to validate_presence_of(:experiment) }
  
  it "parameterizes id and the experiments's param together" do
    experiment = create(:experiment, name: 'TCORS 2')
    post_template = create(:post_template, experiment: experiment)
    post = create(:post, post_template: post_template, experiment: experiment)

    expect(post.to_param).to eq("#{experiment.to_param}-post-#{post.id.to_s}")
  end
end
