require "rails_helper"

RSpec.describe PromoteTwitterMessagesJob, type: :job do
  include ActiveJob::TestHelper
  
  before do
    ActiveJob::Base.queue_adapter = :test
    allow(TwitterAdsClient).to receive(:new)
    @twitter_ads_client = TwitterAdsClient.new
    allow(@twitter_ads_client).to receive(:get_account)
    allow(@twitter_ads_client).to receive(:promote_tweet).with(:account, :line_item_id, :tweet_id)
  end

  it 'queues the job' do
    expect { PromoteTwitterMessagesJob.perform_later }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end
  
  it 'queues the job in the default queue' do
    expect(PromoteTwitterMessagesJob.new.queue_name).to eq('default')
  end

  it 'executes perform' do
    perform_enqueued_jobs { PromoteTwitterMessagesJob.perform_later }
  end

  it 'saves ad_published to true for the published messages' do
    perform_enqueued_jobs { PromoteTwitterMessagesJob.perform_later }
  end
  
  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
