require 'rails_helper'

RSpec.describe ExcelFileReader do
  before do
    @excel_file_reader = ExcelFileReader.new
  end

  it 'successfully reads a Excel file from a URL' do
    excel_url = 'http://sc-ctsi.org/trial-promoter/message_templates.xlsx'
    sample_excel_content = [["content", "platform", "hashtags", "tag_list", "website_url", "website_name"], ["This is the first message template.", "twitter", "#hashtag1, #hashtag2", "theme-1, stem-1", "http://www.url1", "Smoking cessation"], ["This is the second message template.", "twitter", "#hashtag1, #hashtag2", "theme-1, stem-2", "http://www.url1", "Smoking cessation"]]
    excel_content = ''

    WebMock.allow_net_connect!
    VCR.turn_off!

    excel_content = @excel_file_reader.read(excel_url)

    WebMock.disable_net_connect!
    VCR.turn_on!

    expect(excel_content).to eq(sample_excel_content)
  end
end
