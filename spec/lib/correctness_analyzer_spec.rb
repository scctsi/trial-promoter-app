require 'rails_helper'
require 'yaml'

RSpec.describe CorrectnessAnalyzer do
  before do
    @experiment = create(:experiment)
    @messages = create_list(:message, 10, :message_generating => @experiment)
    @correctness_analyzer = CorrectnessAnalyzer.new
  end
  
  describe 'calculating correctness of generated messages' do
    it 'calculates the percentage of messages that replaced the {url} variable' do
      @messages[0..4].each do |message|
        message.content += '{url}'
        message.save
      end
      @messages[5..9].each do |message|
        message.content = 'The URL was successfully replaced. http://www.url.com'
        message.save
      end

      expect(@correctness_analyzer.analyze(@experiment, :url_variable_replaced)).to eq(0.5)
    end
    
    it 'calculates the percentage of messages that included an image' do
      @messages[0..2].each do |message|
        message.image = nil
        message.save
      end
      @messages[3..9].each do |message|
        message.image = create(:image)
        message.save
      end

      expect(@correctness_analyzer.analyze(@experiment, :image_present)).to eq(0.7)
    end
    
    it 'calculates the percentage of messages that included the tracking link' do
      @messages[0..2].each do |message|
        message.click_meter_tracking_link = nil
        message.save
      end
      @messages[3..3].each do |message|
        message.click_meter_tracking_link = ClickMeterTrackingLink.new(:tracking_url => 'http://www.missing-url.com')
        message.content = 'Some content'
        message.save
      end
      @messages[4..9].each do |message|
        message.click_meter_tracking_link = ClickMeterTrackingLink.new(:tracking_url => 'http://www.tracking-url.com')
        message.content = 'Some content ' + message.click_meter_tracking_link.tracking_url
        message.save
      end

      expect(@correctness_analyzer.analyze(@experiment, :tracking_url_present)).to eq(0.6)
    end
    
    it 'calculates the percentage of messages that included a hashtag (if applicable)' do
      @messages[0..2].each do |message|
        message.message_template = build(:message_template)
        message.message_template.hashtags = ['#hashtag1', '#hashtag2']
        message.content = 'Content without hashtag!'
        message.save
      end
      @messages[3..3].each do |message|
        message.message_template = build(:message_template)
        message.message_template.hashtags = ['#hashtag1', '#hashtag2']
        message.content = 'Content with hashtag! #hashtag1'
        message.save
      end
      @messages[4..9].each do |message|
        message.message_template = build(:message_template)
        message.message_template.hashtags = ['#hashtag1', '#hashtag2']
        message.content = 'Content with #hashtag2'
        message.save
      end

      expect(@correctness_analyzer.analyze(@experiment, :hashtag_included_if_applicable)).to eq(0.7)
    end
    
    it 'ignores checking for hashtags if the message template has a nil or blank array of hashtags' do
      @messages[0..2].each do |message|
        message.message_template = build(:message_template)
        message.message_template.hashtags = nil
        message.content = 'Content without hashtag!'
        message.save
      end
      @messages[3..3].each do |message|
        message.message_template = build(:message_template)
        message.message_template.hashtags = []
        message.content = 'Content without hashtag!'
        message.save
      end
      @messages[4..9].each do |message|
        message.message_template = build(:message_template)
        message.message_template.hashtags = ['#hashtag1', '#hashtag2']
        message.content = 'Content with #hashtag2'
        message.save
      end

      expect(@correctness_analyzer.analyze(@experiment, :hashtag_included_if_applicable)).to eq(1.0)
    end
    
    it 'calculates the percentage of messages that linked to the correct website' do
      @messages[0..0].each do |message| # Incorrect #anchor link
        message.promoted_website_url = 'http://staging.befreeoftobacco.org/#death'
        message.click_meter_tracking_link = ClickMeterTrackingLink.new(:destination_url => 'http://staging.befreeoftobacco.org/?utm_source=instagram&utm_campaign=1-tcors-staging&utm_medium=ad&utm_term=&utm_content=1-tcors-staging-message-34007#every-smoke-counts')
        message.save
      end
      @messages[1..1].each do |message| # Incorrect website
        message.promoted_website_url = 'http://staging.befreeoftobacco.org/#death'
        message.click_meter_tracking_link = ClickMeterTrackingLink.new(:destination_url => 'http://befreeoftobacco.org/?utm_source=instagram&utm_campaign=1-tcors-staging&utm_medium=ad&utm_term=&utm_content=1-tcors-staging-message-34007#death')
        message.save
      end
      @messages[2..2].each do |message| # Incorrect website AND anchor link
        message.promoted_website_url = 'http://staging.befreeoftobacco.org/#death'
        message.click_meter_tracking_link = ClickMeterTrackingLink.new(:destination_url => 'http://befreeoftobacco.org/?utm_source=instagram&utm_campaign=1-tcors-staging&utm_medium=ad&utm_term=&utm_content=1-tcors-staging-message-34007#every-smoke-counts')
        message.save
      end
      @messages[3..9].each do |message|
        message.promoted_website_url = 'http://staging.befreeoftobacco.org/#death'
        message.click_meter_tracking_link = ClickMeterTrackingLink.new(:destination_url => 'http://staging.befreeoftobacco.org/?utm_source=instagram&utm_campaign=1-tcors-staging&utm_medium=ad&utm_term=&utm_content=1-tcors-staging-message-34007#death')
        message.save
      end

      expect(@correctness_analyzer.analyze(@experiment, :correct_destination_url)).to eq(0.7)
    end
  end
end