require 'rails_helper'

RSpec.describe PostTemplate, type: :model do
  before do
    @social_media_specification = create(:social_media_specification)
    @experiment = create(:experiment)
  end
    
  it { is_expected.to belong_to :social_media_specification }
  it { is_expected.to validate_presence_of :social_media_specification }
  it { is_expected.to belong_to :experiment }
  it { is_expected.to validate_presence_of :experiment }
  it { is_expected.to serialize(:image_pool).as(Array) }

  it "uses an ActiveRecord store for the content" do
    post_template = PostTemplate.new
    post_template.content[:headline] = "Headline"
    post_template.content[:description] = "Description"
    post_template.social_media_specification = @social_media_specification
    post_template.experiment = @experiment
    
    post_template.save
    
    post_template.reload
    expect(post_template.content[:headline]).to eq("Headline")
    expect(post_template.content['description']).to eq("Description")
  end
end
 
