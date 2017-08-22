require 'rails_helper'

RSpec.describe ExcelFileReader do
  before do
    @excel_file_reader = ExcelFileReader.new
  end

  it 'successfully reads a Excel file from a URL' do
    excel_url = 'http://sc-ctsi.org/trial-promoter/message_templates.xlsx'
    sample_excel_content = [["content", "platorm", "hashtags", "tags", "website_url", "website_name", "theme", "fda_campaign", "stem_id", "lin_meth_factor", "lin_meth_level", "original_image_filenames"], ["#Smoking damages your DNA, which can lead to cancer almost anywhere in your body.", "facebook, instagram, twitter", nil, nil, "sc-ctsi.org", "CTSI [temp]", "health", "FE", "FE53", 1, 1, "background-md-devices_2.jpg"], ["#Smoking damages our DNA, which can lead to cancer almost anywhere in our bodies.", "facebook, instagram, twitter", nil, nil, "sc-ctsi.org", "CTSI [temp]", "health", "FE", "FE53", 1, 2, "background-md-devices_2.jpg"]]
    excel_content = ''

    WebMock.allow_net_connect!
    VCR.turn_off!

    excel_content = @excel_file_reader.read(excel_url)

    WebMock.disable_net_connect!
    VCR.turn_on!

    expect(excel_content).to eq(sample_excel_content)
  end 

  describe "(development only tests)", :development_only_tests => true do
    before do 
      secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
      allow(Setting).to receive(:[]).with(:dropbox_access_token).and_return(secrets['dropbox_access_token'])
    end
    
    it 'successfully reads an Excel (.xlsx) file from a private Dropbox file path' do
      dropbox_file_path = '/tcors/analytics_files/04-19-2017/2017-04-19-to-2017-04-19-6hu9ou4xpw5c.xlsx'
      parsed_excel_content = ''
      
      VCR.use_cassette 'excel_file_reader/read_from_dropbox' do
        parsed_excel_content = ExcelFileReader.read_from_dropbox(dropbox_file_path)
      end
  
      expect(parsed_excel_content.size).to eq(4)
    end
  end
end
