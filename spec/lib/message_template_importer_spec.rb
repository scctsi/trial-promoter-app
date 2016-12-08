require 'rails_helper'

RSpec.describe MessageTemplateImporter do
  before do
    @message_template_importer = MessageTemplateImporter.new
  end
  
  it 'has a predefined column index attribute mapping for message templates' do
    expect(MessageTemplateImporter::COLUMN_INDEX_ATTRIBUTE_MAPPING).to eq({ 0 => 'content', 1 => 'platform', 2 => 'hashtags', 3 => 'tag_list' })
  end

  it 'successfully imports message templates' do
    parsed_csv_content = [['content', 'platform', 'hashtags', 'tags', 'website_url', 'website_name'], ['This is a message template.', 'twitter', '#hashtag1, #hashtag2', 'theme-1, stem-1', 'http://www.url.com', 'Smoking cessation']]
    experiment_tag = '1-tcors'
    
    @message_template_importer.import(parsed_csv_content, experiment_tag)
    
    expect(MessageTemplate.count).to eq(1)
    message_template = MessageTemplate.first
    expect(message_template.content).to eq(parsed_csv_content[1][0])
    expect(message_template.platform).to eq(parsed_csv_content[1][1])
    parsed_tag_list = parsed_csv_content[1][3].split(",").map { |tag| tag.strip }
    expect(message_template.tag_list).to eq(parsed_tag_list)
    expect(message_template.experiment_list).to eq([experiment_tag])
    expect(message_template.hashtags).to eq(['#hashtag1', '#hashtag2'])

    # Also verify that the websites were successfully imported    
    expect(Website.count).to eq(1)
    website = Website.first
    expect(website.name).to eq(parsed_csv_content[1][4])
    expect(website.url).to eq(parsed_csv_content[1][5])
    parsed_tag_list = parsed_csv_content[1][3].split(",").map { |tag| tag.strip }
    expect(website.tag_list).to eq(parsed_tag_list)
    expect(website.experiment_list).to eq([experiment_tag])
  end
end
