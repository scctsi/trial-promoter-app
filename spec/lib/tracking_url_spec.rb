require 'rails_helper'

RSpec.describe TrackingUrl do
  # https://ga-dev-tools.appspot.com/campaign-url-builder/
  before do
    @message = create(:message)
  end
  
  it 'returns a hash of UTM parameters for a message' do
    utm_parameters = TrackingUrl.utm_parameters(@message)
    
    expect(utm_parameters[:source]).to eq(@message.message_template.platform.to_s)
    expect(utm_parameters[:medium]).to eq(@message.medium.to_s)
    expect(utm_parameters[:campaign]).to eq(@message.message_generating.to_param)
    expect(utm_parameters[:term]).to eq(nil)
    expect(utm_parameters[:content]).to eq(@message.to_param)
  end

  it 'gets a campaign URL given a website URL' do
    @message.promotable = build(:website)
    utm_parameters = TrackingUrl.utm_parameters(@message)
    
    campaign_url = TrackingUrl.campaign_url(@message)

    expect(campaign_url).to eq("#{@message.promotable.url}?utm_source=#{utm_parameters[:source]}&utm_campaign=#{utm_parameters[:campaign]}&utm_medium=#{utm_parameters[:medium]}&utm_term=#{utm_parameters[:term]}&utm_content=#{utm_parameters[:content]}")
  end
end