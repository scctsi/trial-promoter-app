require 'rails_helper'

RSpec.describe BasicTrackingLinkClient do
  describe "Basic Tracking Link Client (development only tests)", :development_only_tests => true do 
    before do
      @experiment = build(:experiment)
      allow(BasicTrackingLinkClient).to receive(:post).and_call_original
    end
    
    it 'returns nil for the body of the POST request when creating a tracking link' do
      post_request_body = 'this is a request body'
      
      post_request_body = BasicTrackingLinkClient.post_request_body_for_create_tracking_link(571973, 1501, 'http://www.sc-ctsi.org', '1-tcors-message-1', BijectiveFunction.encode(1))
      
      expect(post_request_body).to eq(nil)
    end
     
    it 'returns nil for a get request instead of returning analytics for a tracking link' do
      post_request_body = 'this is a request body'
      
      post_request_body = BasicTrackingLinkClient.get_tracking_link( '1-tcors-message-1', 'tracking_id')

      expect(post_request_body).to eq(nil)
    end
      
    it 'returns nil instead of updating a tracking link' do
      post_request_body = 'this is a request body'
      
      post_request_body = BasicTrackingLinkClient.update_tracking_link('1-tcors-message-1', 'tracking_id')

      expect(post_request_body).to eq(nil)
    end
 
    it 'creates a fake tracking link' do
      tracking_link = nil

      tracking_link = BasicTrackingLinkClient.create_tracking_link(@experiment, 571973, 1501, 'http://www.sc-ctsi.org', 'SC CTSI', 'name-unique-to-sc-ctsi')

      expect(tracking_link.click_meter_id).to eq('SC CTSI')
      expect(tracking_link.click_meter_uri).to eq('http://www.sc-ctsi.org')  
      expect(tracking_link.tracking_url).to eq('http://www.sc-ctsi.org')  
      expect(tracking_link.destination_url).to eq('http://www.sc-ctsi.org')  
     end
    
    it 'returns nil instead of deleting the tracking_link' do
      tracking_link = 'tracking link'

      tracking_link = BasicTrackingLinkClient.delete_tracking_link('tcors', 234235)
  
      expect(tracking_link).to eq(nil)
    end
      
    it 'returns an empty array instead of the tracking groups' do
      groups = 'groups'
      
      groups = BasicTrackingLinkClient.get_groups('tcors')
  
      expect(groups).to eq([])
    end
            
    it 'returns an empty array instead of the tracking domains' do
      domains = 'domains'
      
      domains = BasicTrackingLinkClient.get_domains('tcors')
  
      expect(domains).to eq([])
    end
     
    it 'creates a fake click meter tracking link for a message' do
      tracking_link = nil
      message = create(:message)
      
      tracking_link = BasicTrackingLinkClient.create_click_meter_tracking_link(@experiment, message, 571973, 1501)

      expect(message.click_meter_tracking_link["click_meter_id"]).to include("-name-message-#{message.id}") 
      expect(message.click_meter_tracking_link["message_id"]).to eq(message.id)
     end
    
    it 'returns an empty array instead of clicks' do
      clicks = [42]

      clicks = BasicTrackingLinkClient.get_clicks('tcors', 'http://www.sc-ctsi.org')
  
      expect(clicks).to eq([])
    end
  end
end
