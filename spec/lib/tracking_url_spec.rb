require 'rails_helper'

RSpec.describe TrackingUrl do
  before do
    message_template = MessageTemplate.new(:initial_id => "1", :content => "Some content", :platform => 'twitter', :message_type => "awareness")
    clinical_trial = ClinicalTrial.new(:title => "Some title", :pi_name => "Jane Doe", :url => "http://www.sc-ctsi.org", :nct_id => "NCT01234567", :initial_database_id => "1")
    @message = Message.new(:content => "Some content", :message_template => message_template, :clinical_trial => clinical_trial)
    @tracking_url = TrackingUrl.new(@message)
  end

  it 'creates a UTM tracking fragment given a campaign, source and medium' do
    source = 'twitter'
    medium = 'post'
    campaign = 'trial-promoter-staging'

    expect(@tracking_url.tracking_fragment(source, medium, campaign)).to eq("utm_source=#{source}&utm_medium=#{medium}&utm_campaign=#{campaign}")
  end

  it 'creates a tracking URL for any given message' do
    medium = 'organic'
    campaign = 'trial-promoter-staging'

    expect(@tracking_url.value(medium, campaign)).to eq("#{@message.clinical_trial.url}/?#{@tracking_url.tracking_fragment(@message.message_template.platform, medium, campaign)}")
  end
end
