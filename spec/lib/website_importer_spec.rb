require 'rails_helper'

RSpec.describe WebsiteImporter do
  before do
    @parsed_csv_content = [["name", "url", "tag"], ["Smoking cessation website", "http://www.url.com", "theme-1, stem-1"]]
    @experiment_tag = '1-tcors'
    @website_importer = WebsiteImporter.new(@parsed_csv_content, @experiment_tag)
  end
  
  it 'defines a post_initialize method which sets the import_class and column_index_attribute_mapping attributes' do
    @website_importer.post_initialize
    expect(@website_importer.import_class).to eq(Website)
    expect(@website_importer.column_index_attribute_mapping).to eq({ 0 => 'name', 1 => 'url', 2 => 'tag_list' })
  end

  it 'successfully imports websites' do
    @website_importer.import
    
    expect(Website.count).to eq(1)
    website = Website.first
    expect(website.name).to eq(@parsed_csv_content[1][0])
    expect(website.url).to eq(@parsed_csv_content[1][1])
    parsed_tag_list = @parsed_csv_content[1][2].split(",").map { |tag| tag.strip }
    expect(website.tag_list).to eq(parsed_tag_list)
    expect(website.experiment_list).to eq([@experiment_tag])
  end
end
