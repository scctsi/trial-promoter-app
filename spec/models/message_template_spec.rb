# == Schema Information
#
# Table name: message_templates
#
#  id         :integer          not null, primary key
#  content    :text
#  platform   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  hashtags   :text
#

require 'rails_helper'

RSpec.describe MessageTemplate do
  it { is_expected.to validate_presence_of :content }
  it { is_expected.to validate_presence_of :platform }
  it { is_expected.to enumerize(:platform).in(:twitter, :facebook, :instagram) }
  it { is_expected.to have_many :messages }

  it 'returns the platform as a symbol' do
    message_template = create(:message_template, platform: 'twitter')
    message_template.reload

    expect(message_template.platform).to be(:twitter)
  end

  it 'stores the experiment variables as a hash' do
    message_template = build(:message_template, platform: 'twitter', experiment_variables: { 'fda_campaign' => '1', 'theme' => '2', 'lin_meth_factor' => '1', 'lin_meth_level' => '3' })

    expect(message_template.experiment_variables).to eq({ 'fda_campaign' => '1', 'theme' => '2', 'lin_meth_factor' => '1', 'lin_meth_level' => '3' })
  end

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

    it 'stores an array of hashtags' do
      @message_template.hashtags = ["#bcsm", "#cancer"]
      @message_template.save
      @message_template.reload

      expect(@message_template.hashtags).to eq(["#bcsm", "#cancer"])
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
end
