require 'rails_helper'

RSpec.describe Importer do
  before do
    @importer = Importer.new
  end
  
  it 'has a predefined column index attribute mapping for message templates' do
    expect(Importer::COLUMN_INDEX_ATTRIBUTE_MAPPINGS[MessageTemplate]).to eq({ 0 => 'content', 1 => 'platform', 2 => 'tag_list', 3 => 'hashtags' })
  end

  it 'has a predefined column index attribute mapping for images' do
    expect(Importer::COLUMN_INDEX_ATTRIBUTE_MAPPINGS[Image]).to eq({ 0 => 'url', 1 => 'original_filename', 2 => 'tag_list' })
  end

  it 'has a predefined column index attribute mapping for websites' do
    expect(Importer::COLUMN_INDEX_ATTRIBUTE_MAPPINGS[Website]).to eq({ 0 => 'title', 1 => 'url', 2 => 'tag_list' })
  end

  it 'successfully imports message templates' do
    parsed_csv_content = [["content", "platform", "tags", "hashtags"], ["This is a message template.", "twitter", "theme-1, stem-1", "#hashtag1, #hashtag2"]]

    @importer.import(MessageTemplate, parsed_csv_content, 'extra-tag')
    
    expect(MessageTemplate.count).to eq(1)
    message_template = MessageTemplate.first
    expect(message_template.content).to eq(parsed_csv_content[1][0])
    expect(message_template.platform).to eq(parsed_csv_content[1][1])
    parsed_tag_list = parsed_csv_content[1][2].split(",").map { |tag| tag.strip }
    expect(message_template.tag_list).to eq(parsed_tag_list.concat(['extra-tag']))
    expect(message_template.hashtags).to eq(['#hashtag1', '#hashtag2'])
  end

  it 'successfully imports websites' do
    parsed_csv_content = [["title", "url", "tag"], ["Smoking cessation website", "http://www.url.com", "theme-1, stem-1"]]

    @importer.import(Website, parsed_csv_content, 'extra-tag')
    
    expect(Website.count).to eq(1)
    website = Website.first
    expect(website.title).to eq(parsed_csv_content[1][0])
    expect(website.url).to eq(parsed_csv_content[1][1])
    parsed_tag_list = parsed_csv_content[1][2].split(",").map { |tag| tag.strip }
    expect(website.tag_list).to eq(parsed_tag_list.concat(['extra-tag']))
  end

  it 'successfully imports images' do
    image_urls = ['http://www.images.com/image1.png', 'http://www.images.com/image2.png']

    @importer.import(Image, image_urls, 'extra-tag')
    
    expect(Image.count).to eq(image_urls.size)
    image = Image.first
    expect(image.url).to eq(image_urls[0])
    expect(image.original_filename).to eq('N/A')
    expect(image.tag_list).to eq(['extra-tag'])
  end
end
