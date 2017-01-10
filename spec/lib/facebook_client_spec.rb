require 'rails_helper'

RSpec.describe FacebookClient do
  before do
    secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
    allow(Setting).to receive(:[]).with(:facebook_access_token).and_return(secrets['facebook_access_token'])
    @facebook_client = FacebookClient.new
    @account = nil
    
    VCR.use_cassette 'facebook_client/test_setup' do
      accounts = @facebook_client.get_accounts
      @account = accounts.first
    end
  end
  
  describe "(development only tests)", :development_only_tests => true do
    it 'initializes the graph for use by the Zuck gem when initialized' do
      facebook_client = nil

      facebook_client = FacebookClient.new

      expect(Zuck.graph).not_to be_nil
    end
    
    it 'returns a list of all ad accounts associated with the user' do
      accounts = nil
      
      VCR.use_cassette 'facebook_client/get_accounts' do
        accounts = @facebook_client.get_accounts
      end
      
      expect(accounts.count).to be >= 1
      expect(accounts.first.account_id).not_to be_nil
      expect(accounts.first.id).to eq("act_#{accounts.first.account_id}")
    end
    
    it 'returns a list of all campaigns associated with an account' do
      campaigns = nil

      VCR.use_cassette 'facebook_client/get_campaigns' do
        campaigns = @facebook_client.get_campaigns(@account)
      end
      
      expect(campaigns.count).to be >= 1
    end
    
    it 'returns true if a campaign (given a name) exists' do
      campaign_exists = false
      
      VCR.use_cassette 'facebook_client/campaign_exists?' do
        campaign_exists = @facebook_client.campaign_exists?(@account, "Test")
      end
      
      expect(campaign_exists).to be true
    end
    
    # These tests write to our ad account on Facebook
    # So all these tests use mocks for testing, thus preventing any real write calls to our ad account
    it 'creates a campaign given a name and objective if the campaign does not exist' do
      allow(@facebook_client).to receive(:campaign_exists?).and_return(false)
      experiment = create(:experiment, name: 'tcors')
      VCR.use_cassette 'facebook_client/create_campaign_if_it_does_not_exist' do
        allow(@account).to receive(:create_campaign)
      end

      @facebook_client.create_campaign(@account, experiment.to_param)
      
      expect(@account).to have_received(:create_campaign).with({name: experiment.to_param, objective: 'LINK_CLICKS'})
    end

    it 'does not create a campaign if the campaign already exists' do
      allow(@facebook_client).to receive(:campaign_exists?).and_return(true)
      experiment = create(:experiment, name: 'tcors')
      VCR.use_cassette 'facebook_client/create_campaign_if_it_does_not_exist' do
        allow(@account).to receive(:create_campaign)
      end

      @facebook_client.create_campaign(@account, experiment.to_param)
      
      expect(@account).not_to have_received(:create_campaign)
    end
    
    it 'creates an adset' do
      
    end
  end
end
