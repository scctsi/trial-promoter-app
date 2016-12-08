require 'rails_helper'

RSpec.describe WebsiteImporter do
  before do
    @website_importer = WebsiteImporter.new
  end
  
  it 'has a predefined CSV file column index attribute mapping' do
    expect(WebsiteImporter::COLUMN_INDEX_ATTRIBUTE_MAPPING).to eq({ 0 => 'name', 1 => 'url', 2 => 'tag_list' })
  end

  it 'successfully imports websites' do
    parsed_csv_content = [["name", "url", "tag"], ["Smoking cessation website", "http://www.url.com", "theme-1, stem-1"]]
    experiment_tag = '1-tcors'

    @website_importer.import(parsed_csv_content, experiment_tag)
    
    expect(Website.count).to eq(1)
    website = Website.first
    expect(website.name).to eq(parsed_csv_content[1][0])
    expect(website.url).to eq(parsed_csv_content[1][1])
    parsed_tag_list = parsed_csv_content[1][2].split(",").map { |tag| tag.strip }
    expect(website.tag_list).to eq(parsed_tag_list)
    expect(website.experiment_list).to eq([experiment_tag])
  end
end
