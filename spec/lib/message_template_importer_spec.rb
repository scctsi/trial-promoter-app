require 'rails_helper'

RSpec.describe MessageTemplateImporter do
  before do
    @parsed_csv_content = [['content', 'platform', 'hashtags', 'tags', 'website_url', 'website_name'], ['This is a message template. {url}', 'twitter', '#hashtag1, #hashtag2', 'theme-1, stem-1', 'http://www.url.com', 'Smoking cessation']]
    @experiment = create(:experiment)
    @experiment_tag = @experiment.to_param
    @message_template_importer = MessageTemplateImporter.new(@parsed_csv_content, @experiment_tag)
  end

  it 'defines a post_initialize method which sets the import_class and column_index_attribute_mapping attributes' do
    @message_template_importer.post_initialize
    
    expect(@message_template_importer.import_class).to eq(MessageTemplate)
    expect(@message_template_importer.column_index_attribute_mapping).to eq({ 0 => 'content', 1 => 'platform', 2 => 'hashtags', 3 => 'tag_list', 6 => 'experiment_variables', 7 => 'original_image_filenames' })
  end

  describe 'pre import prepare method' do
    it 'converts any columns after the 6th column to a hash' do
      @parsed_csv_content = [['content', 'platform', 'hashtags', 'tags', 'website_url', 'website_name', 'theme', 'fda_campaign'], ['This is a message template. {url}', 'twitter', '#hashtag1, #hashtag2', 'theme-1, stem-1', 'http://www.url.com', 'Smoking cessation', '1', '2']]
      prepared_csv_content = @message_template_importer.pre_import_prepare(@parsed_csv_content)
      
      expect(prepared_csv_content).to eq([['content', 'platform', 'hashtags', 'tags', 'website_url', 'website_name', 'experiment_variables'], ['This is a message template. {url}', 'twitter', '#hashtag1, #hashtag2', 'theme-1, stem-1', 'http://www.url.com', 'Smoking cessation', { 'theme' => '1', 'fda_campaign' => '2'}]])
    end

    it 'does not use the content of a column with a header of original_image_filenames in the experiment_variables hash' do
      @parsed_csv_content = [['content', 'platform', 'hashtags', 'tags', 'website_url', 'website_name', 'theme', 'fda_campaign', 'original_image_filenames'], ['This is a message template. {url}', 'twitter', '#hashtag1, #hashtag2', 'theme-1, stem-1', 'http://www.url.com', 'Smoking cessation', '1', '2', 'filename1.png, filename2.png']]
      prepared_csv_content = @message_template_importer.pre_import_prepare(@parsed_csv_content)
      
      expect(prepared_csv_content).to eq([['content', 'platform', 'hashtags', 'tags', 'website_url', 'website_name', 'experiment_variables', 'original_image_filenames'], ['This is a message template. {url}', 'twitter', '#hashtag1, #hashtag2', 'theme-1, stem-1', 'http://www.url.com', 'Smoking cessation', { 'theme' => '1', 'fda_campaign' => '2'}, ['filename1.png', 'filename2.png']]])
    end
  
    it 'converts any row with multiple platforms (comma separated list of platform names) into multiple rows with one platform per row' do
      @parsed_csv_content = [['content', 'platform', 'hashtags', 'tags', 'website_url', 'website_name', 'theme', 'fda_campaign'], ['This is a message template. {url}', 'twitter, facebook, instagram', '#hashtag1, #hashtag2', 'theme-1, stem-1', 'http://www.url.com', 'Smoking cessation', '1', '2']]
      prepared_csv_content = @message_template_importer.pre_import_prepare(@parsed_csv_content)
      
      expect(prepared_csv_content).to eq([['content', 'platform', 'hashtags', 'tags', 'website_url', 'website_name', 'experiment_variables'], ['This is a message template. {url}', 'twitter', '#hashtag1, #hashtag2', 'theme-1, stem-1', 'http://www.url.com', 'Smoking cessation', { 'theme' => '1', 'fda_campaign' => '2'}], ['This is a message template. {url}', 'facebook', '#hashtag1, #hashtag2', 'theme-1, stem-1', 'http://www.url.com', 'Smoking cessation', { 'theme' => '1', 'fda_campaign' => '2'}], ['This is a message template. {url}', 'instagram', '#hashtag1, #hashtag2', 'theme-1, stem-1', 'http://www.url.com', 'Smoking cessation', { 'theme' => '1', 'fda_campaign' => '2'}]])
    end
  
    it 'adds {url} message template variable to the content if it is missing' do
      @parsed_csv_content = [['content', 'platform', 'hashtags', 'tags', 'website_url', 'website_name'], ['This is a message template.', 'twitter', '#hashtag1, #hashtag2', 'theme-1, stem-1', 'http://www.url.com', 'Smoking cessation'], ['This is a message template. {url}', 'twitter', '#hashtag1, #hashtag2', 'theme-1, stem-1', 'http://www.url.com', 'Smoking cessation']]
      prepared_csv_content = @message_template_importer.pre_import_prepare(@parsed_csv_content)
      
      expect(prepared_csv_content).to eq([['content', 'platform', 'hashtags', 'tags', 'website_url', 'website_name'], ['This is a message template.{url}', 'twitter', '#hashtag1, #hashtag2', 'theme-1, stem-1', 'http://www.url.com', 'Smoking cessation'], ['This is a message template. {url}', 'twitter', '#hashtag1, #hashtag2', 'theme-1, stem-1', 'http://www.url.com', 'Smoking cessation']])
    end

    it 'deletes all the message templates associated with the experiment' do
      create_list(:message_template, 2, experiment_list: [@experiment.to_param])
  
      @message_template_importer.pre_import
      
      expect(MessageTemplate.belonging_to(@experiment).count).to eq(0)
    end
  end

  it 'successfully imports message templates' do
    @message_template_importer.import
    
    expect(MessageTemplate.count).to eq(1)
    message_template = MessageTemplate.first
    expect(message_template.content).to eq(@parsed_csv_content[1][0])
    expect(message_template.platform).to eq(@parsed_csv_content[1][1].to_sym)
    parsed_tag_list = @parsed_csv_content[1][3].split(",").map { |tag| tag.strip }
    expect(message_template.tag_list).to eq(parsed_tag_list)
    expect(message_template.experiment_list).to eq([@experiment_tag])
    expect(message_template.hashtags).to eq(['#hashtag1', '#hashtag2'])
  end

  it 'successfully imports extra columns in the parsed CSV content into the experiment variables' do
    @parsed_csv_content = [['content', 'platform', 'hashtags', 'tags', 'website_url', 'website_name', 'theme', 'fda_campaign'], ['This is a message template. {url}', 'twitter', '#hashtag1, #hashtag2', 'theme-1, stem-1', 'http://www.url.com', 'Smoking cessation', '1', '2']]
    @message_template_importer = MessageTemplateImporter.new(@parsed_csv_content, @experiment_tag)

    @message_template_importer.import
    
    expect(MessageTemplate.count).to eq(1)
    message_template = MessageTemplate.first
    expect(message_template.content).to eq(@parsed_csv_content[1][0])
    expect(message_template.platform).to eq(@parsed_csv_content[1][1].to_sym)
    parsed_tag_list = @parsed_csv_content[1][3].split(",").map { |tag| tag.strip }
    expect(message_template.tag_list).to eq(parsed_tag_list)
    expect(message_template.experiment_list).to eq([@experiment_tag])
    expect(message_template.hashtags).to eq(['#hashtag1', '#hashtag2'])
    expect(message_template.experiment_variables).to eq( {'theme' => '1', 'fda_campaign' => '2'} )
  end

  it 'successfully imports original image filenames in the parsed CSV content' do
    @parsed_csv_content = [['content', 'platform', 'hashtags', 'tags', 'website_url', 'website_name', 'theme', 'fda_campaign', 'original_image_filenames'], ['This is a message template. {url}', 'twitter', '#hashtag1, #hashtag2', 'theme-1, stem-1', 'http://www.url.com', 'Smoking cessation', '1', '2', 'filename1.png, filename2.png']]
    @message_template_importer = MessageTemplateImporter.new(@parsed_csv_content, @experiment_tag)

    @message_template_importer.import
    
    expect(MessageTemplate.count).to eq(1)
    message_template = MessageTemplate.first
    expect(message_template.content).to eq(@parsed_csv_content[1][0])
    expect(message_template.platform).to eq(@parsed_csv_content[1][1].to_sym)
    parsed_tag_list = @parsed_csv_content[1][3].split(",").map { |tag| tag.strip }
    expect(message_template.tag_list).to eq(parsed_tag_list)
    expect(message_template.experiment_list).to eq([@experiment_tag])
    expect(message_template.hashtags).to eq(['#hashtag1', '#hashtag2'])
    expect(message_template.experiment_variables).to eq( {'theme' => '1', 'fda_campaign' => '2'} )
    expect(message_template.original_image_filenames).to eq( ['filename1.png', 'filename2.png'] )
  end

  it 'successfully imports message templates where the platform is a comma separated list of platform names' do
    @parsed_csv_content = [['content', 'platform', 'hashtags', 'tags', 'website_url', 'website_name', 'theme', 'fda_campaign'], ['This is a message template. {url}', 'facebook, twitter, instagram', '#hashtag1, #hashtag2', 'theme-1, stem-1', 'http://www.url.com', 'Smoking cessation', '1', '2']]
    @message_template_importer = MessageTemplateImporter.new(@parsed_csv_content, @experiment_tag)

    @message_template_importer.import
    
    expect(MessageTemplate.count).to eq(3)
    MessageTemplate.all.each do |message_template|
      expect(message_template.content).to eq(@parsed_csv_content[1][0])
      parsed_tag_list = @parsed_csv_content[1][3].split(",").map { |tag| tag.strip }
      expect(message_template.tag_list).to eq(parsed_tag_list)
      expect(message_template.experiment_list).to eq([@experiment_tag])
      expect(message_template.hashtags).to eq(['#hashtag1', '#hashtag2'])
      expect(message_template.experiment_variables).to eq( {'theme' => '1', 'fda_campaign' => '2'} )
    end
    expect(MessageTemplate.all[0].platform).to be(:facebook)
    expect(MessageTemplate.all[1].platform).to be(:twitter)
    expect(MessageTemplate.all[2].platform).to be(:instagram)
  end

  it 'successfully imports websites (in a post_import step)' do
    @message_template_importer.post_import(@parsed_csv_content)
    
    expect(Website.count).to eq(1)
    website = Website.first
    expect(website.name).to eq(@parsed_csv_content[1][4])
    expect(website.url).to eq(@parsed_csv_content[1][5])
    parsed_tag_list = @parsed_csv_content[1][3].split(",").map { |tag| tag.strip }
    expect(website.tag_list).to eq(parsed_tag_list)
    expect(website.experiment_list).to eq([@experiment_tag])
  end
  
  it 'successfully fills out the image pool for imported message templates' do
    images = create_list(:image, 4)
    images[0].original_filename = 'filename1.png'
    images[0].experiment_list = @experiment_tag
    images[0].save
    images[1].original_filename = 'filename2.png'
    images[1].experiment_list = @experiment_tag
    images[1].save
    @parsed_csv_content = [['content', 'platform', 'hashtags', 'tags', 'website_url', 'website_name', 'theme', 'fda_campaign', 'original_image_filenames'], ['This is a message template. {url}', 'twitter', '#hashtag1, #hashtag2', 'theme-1, stem-1', 'http://www.url.com', 'Smoking cessation', '1', '2', 'filename1.png, filename2.png']]
    @message_template_importer = MessageTemplateImporter.new(@parsed_csv_content, @experiment_tag)

    @message_template_importer.import

    message_template = MessageTemplate.first
    expect(message_template.image_pool.count).to eq(2)
  end
end