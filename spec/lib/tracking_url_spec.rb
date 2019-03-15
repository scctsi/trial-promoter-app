require 'rails_helper'

RSpec.describe TrackingUrl do
  # https://ga-dev-tools.appspot.com/campaign-url-builder/
  before do
    @message = build(:message)
    social_media_specification = SocialMediaSpecification.new
    social_media_specification.platform = :facebook
    social_media_specification.post_type = :ad
    post_template = PostTemplate.new
    post_template.social_media_specification = social_media_specification
    @post = Post.new
    @post.post_template = post_template
  end
  
  it 'returns a hash of UTM parameters for a message' do
    utm_parameters = TrackingUrl.utm_parameters(@message)
    
    expect(utm_parameters[:source]).to eq(@message.platform)
    expect(utm_parameters[:medium]).to eq(@message.medium)
    expect(utm_parameters[:campaign]).to eq(@message.message_generating.to_param)
    expect(utm_parameters[:term]).to eq(nil)
    expect(utm_parameters[:content]).to eq(@message.to_param)
  end

  it 'returns a hash of UTM parameters for a post' do
    utm_parameters = TrackingUrl.utm_parameters(@post)
    
    expect(utm_parameters[:source]).to eq(@post.post_template.social_media_specification.platform)
    expect(utm_parameters[:medium]).to eq(@post.post_template.social_media_specification.post_type)
    expect(utm_parameters[:campaign]).to eq(@post.experiment.to_param)
    expect(utm_parameters[:term]).to eq(nil)
    expect(utm_parameters[:content]).to eq(@post.to_param)
  end

  it 'gets a tracking URL (campaign URL) for a message' do
    @message.promoted_website_url = 'http://example.com'
    utm_parameters = TrackingUrl.utm_parameters(@message)
    
    campaign_url = TrackingUrl.campaign_url(@message)

    expect(campaign_url).to eq("#{@message.promoted_website_url}?utm_source=#{utm_parameters[:source]}&utm_campaign=#{utm_parameters[:campaign]}&utm_medium=#{utm_parameters[:medium]}&utm_term=#{utm_parameters[:term]}&utm_content=#{utm_parameters[:content]}")
  end

  it 'gets a tracking URL (campaign URL) for a post' do
    @post.content[:website_url] = 'http://example.com'
    utm_parameters = TrackingUrl.utm_parameters(@post)
    
    campaign_url = TrackingUrl.campaign_url(@post)

    expect(campaign_url).to eq("#{@post.content[:website_url]}?utm_source=#{utm_parameters[:source]}&utm_campaign=#{utm_parameters[:campaign]}&utm_medium=#{utm_parameters[:medium]}&utm_term=#{utm_parameters[:term]}&utm_content=#{utm_parameters[:content]}")
  end
  
  it 'appends anchor links to the end when creating a campaign URL' do
    # REF: http://stackoverflow.com/questions/29994275/utm-tags-and-anchors-in-url
    @message.promoted_website_url = 'http://example.com/#anchor-link'
    utm_parameters = TrackingUrl.utm_parameters(@message)
    
    campaign_url = TrackingUrl.campaign_url(@message)

    expect(campaign_url).to eq("#{@message.promoted_website_url}?utm_source=#{utm_parameters[:source]}&utm_campaign=#{utm_parameters[:campaign]}&utm_medium=#{utm_parameters[:medium]}&utm_term=#{utm_parameters[:term]}&utm_content=#{utm_parameters[:content]}#anchor-link")
  end
end