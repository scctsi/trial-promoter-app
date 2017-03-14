require 'rails_helper'

RSpec.describe MessageTemplateImporter do
  before do
    @parsed_excel_content = [['content', 'platforms', 'hashtags', 'tags', 'website_url', 'website_name'], ['This is a message template. {url}', 'twitter', '#hashtag1, #hashtag2', 'theme-1, stem-1', 'http://www.url.com', 'Smoking cessation']]
    @experiment = create(:experiment)
    @experiment_tag = @experiment.to_param
    @message_template_importer = MessageTemplateImporter.new(@parsed_excel_content, @experiment_tag)
  end

  it 'defines a post_initialize method which sets the import_class and column_index_attribute_mapping attributes' do
    @message_template_importer.post_initialize

    expect(@message_template_importer.import_class).to eq(MessageTemplate)
    expect(@message_template_importer.column_index_attribute_mapping).to eq({ 0 => 'content', 1 => 'platforms', 2 => 'hashtags', 3 => 'tag_list', 4 => 'promoted_website_url', 6 => 'experiment_variables', 7 => 'original_image_filenames' })
  end

  describe 'pre import prepare method' do
    it 'converts any columns after the 6th column to a hash' do
      @parsed_excel_content = [['content', 'platforms', 'hashtags', 'tags', 'website_url', 'website_name', 'theme', 'fda_campaign'], ['This is a message template. {url}', 'twitter', '#hashtag1, #hashtag2', 'theme-1, stem-1', 'http://www.url.com', 'Smoking cessation', '1', '2']]
      prepared_excel_content = @message_template_importer.pre_import_prepare(@parsed_excel_content)

      expect(prepared_excel_content).to eq([['content', 'platforms', 'hashtags', 'tags', 'website_url', 'website_name', 'experiment_variables'], ['This is a message template. {url}', [:twitter], '#hashtag1, #hashtag2', 'theme-1, stem-1', 'http://url.com', 'Smoking cessation', { 'theme' => '1', 'fda_campaign' => '2'}]])
    end

    it 'does not use the content of a column with a header of original_image_filenames in the experiment_variables hash' do
      @parsed_excel_content = [['content', 'platforms', 'hashtags', 'tags', 'website_url', 'website_name', 'theme', 'fda_campaign', 'original_image_filenames'], ['This is a message template. {url}', 'twitter', '#hashtag1, #hashtag2', 'theme-1, stem-1', 'http://www.url.com', 'Smoking cessation', '1', '2', 'filename1.png, filename2.png']]
      prepared_excel_content = @message_template_importer.pre_import_prepare(@parsed_excel_content)

      expect(prepared_excel_content).to eq([['content', 'platforms', 'hashtags', 'tags', 'website_url', 'website_name', 'experiment_variables', 'original_image_filenames'], ['This is a message template. {url}', [:twitter], '#hashtag1, #hashtag2', 'theme-1, stem-1', 'http://url.com', 'Smoking cessation', { 'theme' => '1', 'fda_campaign' => '2'}, ['filename1.png', 'filename2.png']]])
    end

    it 'converts multiple platforms (comma separated list of platform names) into an array of platform symbols' do
      @parsed_excel_content = [['content', 'platforms', 'hashtags', 'tags', 'website_url', 'website_name', 'theme', 'fda_campaign'], ['This is a message template. {url}', 'twitter, facebook, instagram', '#hashtag1, #hashtag2', 'theme-1, stem-1', 'http://www.url.com', 'Smoking cessation', '1', '2']]
      prepared_excel_content = @message_template_importer.pre_import_prepare(@parsed_excel_content)

      expect(prepared_excel_content).to eq([['content', 'platforms', 'hashtags', 'tags', 'website_url', 'website_name', 'experiment_variables'], ['This is a message template. {url}', [:twitter, :facebook, :instagram], '#hashtag1, #hashtag2', 'theme-1, stem-1', 'http://url.com', 'Smoking cessation', { 'theme' => '1', 'fda_campaign' => '2'}]])
    end

    it 'adds {url} message template variable to the content if it is missing' do
      @parsed_excel_content = [['content', 'platforms', 'hashtags', 'tags', 'website_url', 'website_name'], ['This is a message template.', 'twitter', '#hashtag1, #hashtag2', 'theme-1, stem-1', 'http://www.url.com', 'Smoking cessation'], ['This is a message template. {url}', 'twitter', '#hashtag1, #hashtag2', 'theme-1, stem-1', 'http://www.url.com', 'Smoking cessation']]
      prepared_excel_content = @message_template_importer.pre_import_prepare(@parsed_excel_content)

      expect(prepared_excel_content).to eq([['content', 'platforms', 'hashtags', 'tags', 'website_url', 'website_name'], ['This is a message template.{url}', [:twitter], '#hashtag1, #hashtag2', 'theme-1, stem-1', 'http://url.com', 'Smoking cessation'], ['This is a message template. {url}', [:twitter], '#hashtag1, #hashtag2', 'theme-1, stem-1', 'http://url.com', 'Smoking cessation']])
    end

    it 'converts a nil value for original image filenames to an empty array' do
      @parsed_excel_content = [['content', 'platforms', 'hashtags', 'tags', 'website_url', 'website_name', 'theme', 'fda_campaign', 'original_image_filenames'], ['This is a message template. {url}', 'twitter', '#hashtag1, #hashtag2', 'theme-1, stem-1', 'http://www.url.com', 'Smoking cessation', '1', '2', nil]]
      prepared_excel_content = @message_template_importer.pre_import_prepare(@parsed_excel_content)

      expect(prepared_excel_content).to eq([['content', 'platforms', 'hashtags', 'tags', 'website_url', 'website_name', 'experiment_variables', 'original_image_filenames'], ['This is a message template. {url}', [:twitter], '#hashtag1, #hashtag2', 'theme-1, stem-1', 'http://url.com', 'Smoking cessation', { 'theme' => '1', 'fda_campaign' => '2'}, []]])
    end

    it 'converts a blank value for original image filenames to an empty array' do
      @parsed_excel_content = [['content', 'platforms', 'hashtags', 'tags', 'website_url', 'website_name', 'theme', 'fda_campaign', 'original_image_filenames'], ['This is a message template. {url}', 'twitter', '#hashtag1, #hashtag2', 'theme-1, stem-1', 'http://www.url.com', 'Smoking cessation', '1', '2', '']]
      prepared_excel_content = @message_template_importer.pre_import_prepare(@parsed_excel_content)

      expect(prepared_excel_content).to eq([['content', 'platforms', 'hashtags', 'tags', 'website_url', 'website_name', 'experiment_variables', 'original_image_filenames'], ['This is a message template. {url}', [:twitter], '#hashtag1, #hashtag2', 'theme-1, stem-1', 'http://url.com', 'Smoking cessation', { 'theme' => '1', 'fda_campaign' => '2'}, []]])
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
    expect(message_template.content).to eq(@parsed_excel_content[1][0])
    expect(message_template.platforms).to eq(@parsed_excel_content[1][1])
    parsed_tag_list = @parsed_excel_content[1][3].split(",").map { |tag| tag.strip }
    expect(message_template.tag_list).to eq(parsed_tag_list)
    expect(message_template.experiment_list).to eq([@experiment_tag])
    expect(message_template.hashtags).to eq(['#hashtag1', '#hashtag2'])
    expect(message_template.promoted_website_url).to eq('http://url.com')
  end

  it 'successfully imports message templates from an Excel file hosted at a URL' do
    reader = ExcelFileReader.new

    WebMock.allow_net_connect!
    VCR.turn_off!
    content = reader.read('http://sc-ctsi.org/trial-promoter/message_templates.xlsx')
    WebMock.disable_net_connect!
    VCR.turn_on!
    @message_template_importer = MessageTemplateImporter.new(content, @experiment_tag)
    @message_template_importer.import

    expect(MessageTemplate.count).to eq(2)
    message_template = MessageTemplate.first
    expect(message_template.content).to eq(content[1][0] + '{url}')
    expect(message_template.platforms.texts).to match_array(["Facebook", "Twitter", "Instagram"])
    expect(message_template.tag_list).to eq([])
    expect(message_template.experiment_list).to eq([@experiment_tag])
    expect(message_template.hashtags).to eq([])
  end

  it 'successfully imports extra columns in the parsed CSV content into the experiment variables' do
    @parsed_excel_content = [['content', 'platforms', 'hashtags', 'tags', 'website_url', 'website_name', 'theme', 'fda_campaign'], ['This is a message template. {url}', 'twitter', '#hashtag1, #hashtag2', 'theme-1, stem-1', 'http://www.url.com', 'Smoking cessation', '1', '2']]
    @message_template_importer = MessageTemplateImporter.new(@parsed_excel_content, @experiment_tag)

    @message_template_importer.import

    expect(MessageTemplate.count).to eq(1)
    message_template = MessageTemplate.first
    expect(message_template.content).to eq(@parsed_excel_content[1][0])
    expect(message_template.platforms).to eq([:twitter])
    parsed_tag_list = @parsed_excel_content[1][3].split(",").map { |tag| tag.strip }
    expect(message_template.tag_list).to eq(parsed_tag_list)
    expect(message_template.experiment_list).to eq([@experiment_tag])
    expect(message_template.hashtags).to eq(['#hashtag1', '#hashtag2'])
    expect(message_template.experiment_variables).to eq( {'theme' => '1', 'fda_campaign' => '2'} )
    expect(message_template.promoted_website_url).to eq('http://url.com')
  end

  it 'successfully imports original image filenames in the parsed CSV content' do
    @parsed_excel_content = [['content', 'platforms', 'hashtags', 'tags', 'website_url', 'website_name', 'theme', 'fda_campaign', 'original_image_filenames'], ['This is a message template. {url}', 'twitter', '#hashtag1, #hashtag2', 'theme-1, stem-1', 'http://www.url.com', 'Smoking cessation', '1', '2', 'filename1.png, filename2.png']]
    @message_template_importer = MessageTemplateImporter.new(@parsed_excel_content, @experiment_tag)

    @message_template_importer.import

    expect(MessageTemplate.count).to eq(1)
    message_template = MessageTemplate.first
    expect(message_template.content).to eq(@parsed_excel_content[1][0])
    expect(message_template.platforms).to eq([:twitter])
    parsed_tag_list = @parsed_excel_content[1][3].split(",").map { |tag| tag.strip }
    expect(message_template.tag_list).to eq(parsed_tag_list)
    expect(message_template.experiment_list).to eq([@experiment_tag])
    expect(message_template.hashtags).to eq(['#hashtag1', '#hashtag2'])
    expect(message_template.experiment_variables).to eq( {'theme' => '1', 'fda_campaign' => '2'} )
    expect(message_template.original_image_filenames).to eq( ['filename1.png', 'filename2.png'] )
    expect(message_template.promoted_website_url).to eq('http://url.com')
  end

  it 'successfully imports blank values for original image filenames in the parsed CSV content' do
    @parsed_excel_content = [['content', 'platforms', 'hashtags', 'tags', 'website_url', 'website_name', 'theme', 'fda_campaign', 'original_image_filenames'], ['This is a message template. {url}', 'twitter', '#hashtag1, #hashtag2', 'theme-1, stem-1', 'http://www.url.com', 'Smoking cessation', '1', '2', '']]
    @message_template_importer = MessageTemplateImporter.new(@parsed_excel_content, @experiment_tag)

    @message_template_importer.import

    expect(MessageTemplate.count).to eq(1)
    message_template = MessageTemplate.first
    expect(message_template.content).to eq(@parsed_excel_content[1][0])
    expect(message_template.platforms).to eq([:twitter])
    parsed_tag_list = @parsed_excel_content[1][3].split(",").map { |tag| tag.strip }
    expect(message_template.tag_list).to eq(parsed_tag_list)
    expect(message_template.experiment_list).to eq([@experiment_tag])
    expect(message_template.hashtags).to eq(['#hashtag1', '#hashtag2'])
    expect(message_template.experiment_variables).to eq( {'theme' => '1', 'fda_campaign' => '2'} )
    expect(message_template.original_image_filenames).to eq( [] )
    expect(message_template.promoted_website_url).to eq('http://url.com')
  end

  it 'successfully imports message templates where the platform is a comma separated list of platform names' do
    @parsed_excel_content = [['content', 'platforms', 'hashtags', 'tags', 'website_url', 'website_name', 'theme', 'fda_campaign'], ['This is a message template. {url}', 'facebook, twitter, instagram', '#hashtag1, #hashtag2', 'theme-1, stem-1', 'http://www.url.com', 'Smoking cessation', '1', '2']]
    @message_template_importer = MessageTemplateImporter.new(@parsed_excel_content, @experiment_tag)

    @message_template_importer.import

    expect(MessageTemplate.count).to eq(1)
    MessageTemplate.all.each do |message_template|
      expect(message_template.content).to eq(@parsed_excel_content[1][0])
      parsed_tag_list = @parsed_excel_content[1][3].split(",").map { |tag| tag.strip }
      expect(message_template.tag_list).to eq(parsed_tag_list)
      expect(message_template.experiment_list).to eq([@experiment_tag])
      expect(message_template.hashtags).to eq(['#hashtag1', '#hashtag2'])
      expect(message_template.experiment_variables).to eq( {'theme' => '1', 'fda_campaign' => '2'} )
      expect(message_template.promoted_website_url).to eq('http://url.com')
    end
    expect(MessageTemplate.first.platforms).to eq([:facebook, :twitter, :instagram])
  end

  it 'successfully fills out the image pool for imported message templates' do
    images = create_list(:image, 4)
    images[0].original_filename = 'filename1.png'
    images[0].experiment_list = @experiment_tag
    images[0].save
    images[1].original_filename = 'filename2.png'
    images[1].experiment_list = @experiment_tag
    images[1].save
    @parsed_excel_content = [['content', 'platform', 'hashtags', 'tags', 'website_url', 'website_name', 'theme', 'fda_campaign', 'original_image_filenames'], ['This is a message template. {url}', 'twitter', '#hashtag1, #hashtag2', 'theme-1, stem-1', 'http://www.url.com', 'Smoking cessation', '1', '2', 'filename1.png, filename2.png']]
    @message_template_importer = MessageTemplateImporter.new(@parsed_excel_content, @experiment_tag)

    @message_template_importer.import

    message_template = MessageTemplate.first
    expect(message_template.image_pool.count).to eq(2)
  end
end