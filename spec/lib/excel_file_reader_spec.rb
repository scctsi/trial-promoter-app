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
end
