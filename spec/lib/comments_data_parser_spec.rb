require 'rails_helper'

RSpec.describe CommentsDataParser do
  before do
    @messages = create_list(:message, 3)
    @comments = create_list(:comment, 3)
    @data = OpenStruct.new
    @data.column_headers = ['Date of Message', 'Message', 'Date of Comment', 'Comment', 'Commentator Username', 'Action Taken', 'Comment Type', 'Comment Syntax', 'Rationale(s) for Action/Categorization', 'Notes']
    @data.rows = [] 
    @data.rows << [@messages[0].scheduled_date_time, @messages[0].content, @comments[0].comment_date, @comments[0].content, @comments[0].commentator_username, '1', '1', '10', '12', '']
  end

  it 'converts an Excel (.xlsx) file of facebook comments to parseable data' do
    excel_content = ExcelFileReader.new.read("#{Rails.root}/spec/fixtures/facebook_comments.xlsx")

    parseable_data = CommentsDataParser.convert_to_parseable_data(excel_content)

    expect(parseable_data.column_headers).to eq(['Date of Message', 'Message', 'Date of Comment', 'Comment', 'Commentator Username', 'Action Taken', 'Comment Type', 'Comment Syntax', 'Rationale(s) for Action/Categorization', 'Notes'])
    expect(parseable_data.rows).to eq(excel_content[1..-1])
  end

  it 'parses data into a format that can be used to add comments to individual messages' do
    parsed_data = CommentsDataParser.parse(@data)

    expect(parsed_data).to eq( @messages[0].to_param => {"Date of Message"=> nil, "Date of Comment"=> nil, "Comment"=>"This message is offensive to me.", "Commentator Username"=>"tater_tot_bot_2000", "Action Taken"=>"1", "Comment Type"=>"1", "Comment Syntax"=>"10", "Rationale(s) for Action/Categorization"=>"12", "Notes"=>"" })
  end
end