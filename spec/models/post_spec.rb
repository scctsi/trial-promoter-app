require 'rails_helper'

describe Post do
  it { is_expected.to belong_to :post_template }
  it { is_expected.to validate_presence_of(:post_template) }
  it { is_expected.to belong_to(:experiment) }
  it { is_expected.to validate_presence_of(:experiment) }
  it { is_expected.to have_many(:metrics) }
  
  it "parameterizes id and the experiments's param together" do
    experiment = create(:experiment, name: 'TCORS 2')
    post_template = create(:post_template, experiment: experiment)
    post = create(:post, post_template: post_template, experiment: experiment)

    expect(post.to_param).to eq("#{experiment.to_param}-post-#{post.id}")
  end

  it 'finds a post by the param' do
    create(:post)

    post = Post.find_by_param(Post.first.to_param)

    expect(post).to eq(Post.first)
  end
  
  it "uses an ActiveRecord store for the content" do
    post = Post.new
    post.content[:headline] = "Headline"
    post.content[:description] = "Description"
    post.post_template = create(:post_template)
    post.experiment = create(:experiment)

    post.save
    
    post.reload
    expect(post.content[:headline]).to eq("Headline")
    expect(post.content['description']).to eq("Description")
  end


end
