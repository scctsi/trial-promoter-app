require 'rails_helper'

RSpec.describe Importer do
  before do
    @importer = Importer.new
  end
  
  it 'successfully imports message templates' do
    parsed_csv_content = [["content", "platform", "tags"], ["This is a message template.", "twitter", "theme-1, stem-1"]]
    column_index_attribute_mapping = {0 => 'content', 1 => 'platform', 2 => 'tag_list'}

    @importer.import(MessageTemplate, parsed_csv_content, column_index_attribute_mapping)
    
    expect(MessageTemplate.count).to eq(1)
    message_template = MessageTemplate.first
    expect(message_template.content).to eq(parsed_csv_content[1][0])
    expect(message_template.platform).to eq(parsed_csv_content[1][1])
    parsed_tag_list = parsed_csv_content[1][2].split(",").map { |tag| tag.strip }
    expect(message_template.tag_list).to eq(parsed_tag_list)
  end
end
