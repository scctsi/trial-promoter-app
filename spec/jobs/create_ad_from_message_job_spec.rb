require "rails_helper"

RSpec.describe CreateAdFromMessageJob, type: :job do
  include ActiveJob::TestHelper
  
  before do
    ActiveJob::Base.queue_adapter = :test
    @facebook_ads_client = FacebookAdsClient.new('act_115443465928527')
    allow(FacebookAdsClient).to receive(:new).and_return(@facebook_ads_client)
    @campaign_id = "120330000027414503"
    
    @messages = build_list(:message, 5)
    (0..1).each do |index|
      @messages[index].ad_published = nil
      @messages[index].medium = :ad
      @messages[index].platform = :facebook
    end

    @messages[2].ad_published = nil
    @messages[2].medium = :ad
    @messages[2].platform = :twitter
    
    @messages[3].ad_published = nil
    @messages[3].medium = :organic
    @messages[3].platform = :facebook
    
    @messages[4].ad_published = true
    @messages[4].medium = :organic
    @messages[4].platform = :facebook
    
    @ad_creatives = [OpenStruct.new, OpenStruct.new]
    @ad_creatives[0].id = "1001"
    @ad_creatives[1].id = "1002"
    @ad_sets = [OpenStruct.new, OpenStruct.new]
    @ad_sets[0].id = "2001"
    @ad_sets[1].id = "2002"
    
    @messages.each do |message|
      message.save
    end
    
    # Set up mocks for creating specific ad creatives and ad sets
    (0..1).each do |index|
      allow(@facebook_ads_client).to receive(:create_ad_creative_from_message).with(@messages[index]).and_return(@ad_creatives[index])
      allow(@facebook_ads_client).to receive(:create_ad_set_from_message).with(@campaign_id, @messages[index]).and_return(@ad_sets[index])
      allow(@facebook_ads_client).to receive(:create_ad_from_ad_creative_and_ad_set)
    end
  end
  
  it 'queues the job' do
    expect { CreateAdFromMessageJob.perform_later }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end
  
  it 'queues the job in the default queue' do
    expect(CreateAdFromMessageJob.new.queue_name).to eq('default')
  end

  it 'executes perform' do
    perform_enqueued_jobs { CreateAdFromMessageJob.perform_later }
  end
  
  it 'executes perform on facebook ads that have not been published' do
    (0..1).each do |index|
      expect(@facebook_ads_client).to receive(:create_ad_creative_from_message).with(@messages[index])
      expect(@facebook_ads_client).to receive(:create_ad_set_from_message).with(@campaign_id, @messages[index])
      expect(@facebook_ads_client).to receive(:create_ad_from_ad_creative_and_ad_set).with(@ad_creatives[index].id, @ad_sets[index].id)
    end

    perform_enqueued_jobs { CreateAdFromMessageJob.perform_later }
  end
  
  it 'does not execute perform on non-facebook message' do
    expect(@facebook_ads_client).not_to receive(:create_ad_creative_from_message).with(@messages[2])
    expect(@facebook_ads_client).not_to receive(:create_ad_set_from_message).with(@campaign_id, @messages[2])
  end
  
  it 'does not execute perform on non-ad message' do
    expect(@facebook_ads_client).not_to receive(:create_ad_creative_from_message).with(@messages[3])
    expect(@facebook_ads_client).not_to receive(:create_ad_set_from_message).with(@campaign_id, @messages[3])
  end  
  
  it 'does not execute perform on published message' do
    expect(@facebook_ads_client).not_to receive(:create_ad_creative_from_message).with(@messages[4])
    expect(@facebook_ads_client).not_to receive(:create_ad_set_from_message).with(@campaign_id, @messages[4])
  end
  
  it 'saves ad_published to true for the published messages' do
    perform_enqueued_jobs { CreateAdFromMessageJob.perform_later }
    
    @messages.each{ |message| message.reload }
    
    expect(@messages[0].ad_published).to be(true)
    expect(@messages[1].ad_published).to be(true)
    expect(@messages[2].ad_published).to be(nil)
    expect(@messages[3].ad_published).to be(nil)
  end
  
  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end