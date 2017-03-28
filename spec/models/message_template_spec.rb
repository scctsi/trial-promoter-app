# == Schema Information
#
# Table name: message_templates
#
#  id                       :integer          not null, primary key
#  content                  :text
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  hashtags                 :text
#  experiment_variables     :text
#  image_pool               :text
#  original_image_filenames :text
#  platforms                :text
#  promoted_website_url     :string(2000)
#

require 'rails_helper'

RSpec.describe MessageTemplate do
  it { is_expected.to validate_presence_of :content }
  it { is_expected.to validate_presence_of :platforms }
  it { is_expected.to validate_presence_of :promoted_website_url }
  it { is_expected.to enumerize(:platforms).in(:twitter, :facebook, :instagram).with_multiple(true) }
  it { is_expected.to have_many :messages }
  it { is_expected.to serialize(:platforms).as(Array) }
  it { is_expected.to serialize(:hashtags).as(Array) }
  it { is_expected.to serialize(:experiment_variables).as(Hash) }
  it { is_expected.to serialize(:original_image_filenames).as(Array) }
  it { is_expected.to serialize(:image_pool).as(Array) }

  describe 'standardizing variables' do
    it 'downcases the pi_first_name variable' do
      message_template = MessageTemplate.new(content: 'This is a message_template containing a {PI_first_name} variable')

      expect(message_template.content).to eq('This is a message_template containing a {pi_first_name} variable')
    end

    it 'downcases the pi_last_name variable' do
      message_template = MessageTemplate.new(content: 'This is a message_template containing a {pi_last_NAME} variable')

      expect(message_template.content).to eq('This is a message_template containing a {pi_last_name} variable')
    end

    it 'downcases the disease variable' do
      message_template = MessageTemplate.new(content: 'This is a message_template containing a {Disease} variable')

      expect(message_template.content).to eq('This is a message_template containing a {disease} variable')
    end

    it 'downcases the url variable' do
      message_template = MessageTemplate.new(content: 'This is a message_template containing a {URL} variable')

      expect(message_template.content).to eq('This is a message_template containing a {url} variable')
    end

    it 'strips out whitespace in the pi_first_name variable' do
      message_template = MessageTemplate.new(content: 'This is a message_template containing a { PI_first_name } variable with whitespace')

      expect(message_template.content).to eq('This is a message_template containing a {pi_first_name} variable with whitespace')
    end

    it 'strips out whitespace in the pi_last_name variable' do
      message_template = MessageTemplate.new(content: 'This is a message_template containing a {pi_last_NAME  } variable with whitespace')

      expect(message_template.content).to eq('This is a message_template containing a {pi_last_name} variable with whitespace')
    end

    it 'strips out whitespace in the disease variable' do
      message_template = MessageTemplate.new(content: 'This is a message_template containing a {  Disease} variable with whitespace')

      expect(message_template.content).to eq('This is a message_template containing a {disease} variable with whitespace')
    end

    it 'strips out whitespace in the url variable' do
      message_template = MessageTemplate.new(content: 'This is a message_template containing a { url } variable with whitespace')

      expect(message_template.content).to eq('This is a message_template containing a {url} variable with whitespace')
    end

    it 'strips out whitespace and downcases multiple and different variables' do
      message_template = MessageTemplate.new(content: 'This is a message_template containing {  Disease}, {PI_first_name }, {PI_LAST_NAME  } variables')

      expect(message_template.content).to eq('This is a message_template containing {disease}, {pi_first_name}, {pi_last_name} variables')
    end

    it 'strips out whitespace and downcases multiple and duplicate variables' do
      message_template = MessageTemplate.new(content: 'This is a message_template containing {  Disease}, {PI_first_name }, {PI_LAST_NAME  } variables which are duplicated here: {  Disease}, {PI_first_name }, {PI_LAST_NAME  }')

      expect(message_template.content).to eq('This is a message_template containing {disease}, {pi_first_name}, {pi_last_name} variables which are duplicated here: {disease}, {pi_first_name}, {pi_last_name}')
    end
  end

  it 'is taggable with a single tag' do
    message_template = create(:message_template)

    message_template.tag_list.add('friendly')
    message_template.save
    message_template.reload

    expect(message_template.tags.count).to eq(1)
    expect(message_template.tags[0].name).to eq('friendly')
  end

  it 'is taggable with multiple tags (some of them multi-word tags)' do
    message_template = create(:message_template)

    message_template.tag_list.add('friendly', 'with emoji')
    message_template.save
    message_template.reload

    expect(message_template.tags.count).to eq(2)
    expect(message_template.tags[0].name).to eq('friendly')
    expect(message_template.tags[1].name).to eq('with emoji')
  end

  it 'is taggable on experiments with a single tag' do
    message_template = create(:message_template)

    message_template.experiment_list.add('tcors')
    message_template.save
    message_template.reload

    expect(message_template.experiments.count).to eq(1)
    expect(message_template.experiments[0].name).to eq('tcors')
  end

  it 'is taggable on experiments with multiple tags (some of them multi-word tags)' do
    message_template = create(:message_template)

    message_template.experiment_list.add('tcors', 'tcors 2')
    message_template.save
    message_template.reload

    expect(message_template.experiments.count).to eq(2)
    expect(message_template.experiments[0].name).to eq('tcors')
    expect(message_template.experiments[1].name).to eq('tcors 2')
  end

  it 'has a scope for finding message templates that belong to an experiment' do
    experiments = create_list(:experiment, 3)
    message_templates = create_list(:message_template, 3)
    message_templates.each.with_index do |message_template, index|
      message_template.experiment_list = experiments[index].to_param
      message_template.save
    end

    message_templates_for_first_experiment = MessageTemplate.belonging_to(experiments[0])

    expect(message_templates_for_first_experiment.count).to eq(1)
    expect(message_templates_for_first_experiment[0].experiment_list).to eq([experiments[0].to_param])
  end

  describe 'storing hashtags' do
    before do
      @message_template = create(:message_template)
    end

    it 'returns an empty array if hashtags is blank or nil' do
      @message_template.hashtags = nil
      @message_template.save
      @message_template.reload

      expect(@message_template.hashtags).to eq([])

      @message_template.hashtags = ''
      @message_template.save
      @message_template.reload

      expect(@message_template.hashtags).to eq([])
    end
    
    it 'stores comma separated strings as an array of hashtags' do
      @message_template.hashtags = "#bcsm, #cancer"
      @message_template.save
      @message_template.reload

      expect(@message_template.hashtags).to eq(["#bcsm", "#cancer"])
    end

    it 'adds a leading hash (#) to any string in an array of hashtags that is missing one' do
      @message_template.hashtags = ["#bcsm", "cancer"]
      @message_template.save
      @message_template.reload

      expect(@message_template.hashtags).to eq(["#bcsm", "#cancer"])
    end

    it 'adds a leading hash (#) to any string in comma separayed strings that is missing one' do
      @message_template.hashtags = "#bcsm, cancer"
      @message_template.save
      @message_template.reload

      expect(@message_template.hashtags).to eq(["#bcsm", "#cancer"])
    end
  end
  
  describe 'warning messages' do
    before do
      @message_template = build(:message_template)
      @message_template.platforms = [:twitter]
    end

    it "returns an empty array if the message template's content is nil" do
      @message_template.content = nil
      
      expect(@message_template.warnings).to eq([])
    end

    it 'only returns warning messages if the platforms for the message template includes Twitter' do
      @message_template.platforms = [:facebook, :instagram]
      @message_template.content = 'A' * 141
      
      expect(@message_template.warnings.count).to eq(0)
    end

    it 'returns a warning if the content is too long for Twitter' do
      @message_template.content = 'A' * 141
      
      expect(@message_template.warnings.count).to eq(1)
      expect(@message_template.warnings[0]).to eq('Too long for use in Twitter')
    end

    it 'returns a warning if the content is too long for Twitter (including a URL)' do
      @message_template.content = "#{'A' * 118}{url}"

      expect(@message_template.warnings.count).to eq(1)
      expect(@message_template.warnings[0]).to eq('Too long for use in Twitter (URL takes up 23 characters)')
    end

    it 'does not raise an error if the hashtags are an empty array' do
      @message_template.hashtags = []
      @message_template.content = "#{'A' * 118}{url}"

      expect(@message_template.warnings.count).to eq(1)
      expect(@message_template.warnings[0]).to eq('Too long for use in Twitter (URL takes up 23 characters)')
    end

    it 'returns a warning if the content is too long for Twitter (including a single hashtag)' do
      @message_template.hashtags = ['#hashtag1']
      @message_template.content = 'A' * (141 - '#hashtag1'.length)

      expect(@message_template.warnings.count).to eq(1)
      expect(@message_template.warnings[0]).to eq('Too long for use in Twitter (None of the hashtags will ever be included)')
    end

    it 'returns a warning if the content is too long for Twitter (including any of the allowed hashtags)' do
      @message_template.hashtags = ['#hashtag1', '#longer-hashtag1', '#longest-hashtag1', '#tag']
      @message_template.content = 'A' * (141 - '#tag'.length)

      expect(@message_template.warnings.count).to eq(1)
      expect(@message_template.warnings[0]).to eq('Too long for use in Twitter (None of the hashtags will ever be included)')
    end

    it 'returns a warning if the content is too long for Twitter (at least any of the allowed hashtags will never be included)' do
      @message_template.hashtags = ['#hashtag1', '#longer-hashtag1', '#longest-hashtag1', '#tag']
      @message_template.content = 'A' * (141 - '#longer-hashtag1'.length)

      expect(@message_template.warnings.count).to eq(1)
      expect(@message_template.warnings[0]).to eq('Too long for use in Twitter (At least one of the hashtags will never be included)')
    end
  end
  
  describe 'storing promoted website URLs in a canonical format' do
    it 'removes www' do
      message_template = build(:message_template)
      message_template.promoted_website_url = 'http://www.url.com'
      
      message_template.save
      message_template.reload
      
      expect(message_template.promoted_website_url).to eq('http://url.com')
    end

    it 'lowercases the URL' do
      message_template = build(:message_template)
      message_template.promoted_website_url = 'http://URL.com'
      
      message_template.save
      message_template.reload
      
      expect(message_template.promoted_website_url).to eq('http://url.com')
    end
    
    it 'adds a scheme' do
      message_template = build(:message_template)
      message_template.promoted_website_url = 'url.com'
      
      message_template.save
      message_template.reload
      
      expect(message_template.promoted_website_url).to eq('http://url.com')
    end
    
    it 'keeps anchor links at the end of a URL (even if this is not according to the standards)' do
      message_template = build(:message_template)
      message_template.promoted_website_url = 'http://url.com/#anchor'
      
      message_template.save
      message_template.reload
      
      expect(message_template.promoted_website_url).to eq('http://url.com/#anchor')
    end

  end
  
end
