# == Schema Information
#
# Table name: comments
#
#  id                   :integer          not null, primary key
#  message_date         :date
#  content              :text
#  comment_date         :date
#  comment_text         :text
#  commentator_username :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  message_id           :string
#  toxicity_score       :string
#  url                  :string
#

require 'rails_helper'

describe Comment do
  it { is_expected.to belong_to :message }

  before do
    @comments = create_list(:comment, 3)
    @message = create(:message)
    @message.comments = @comments
    @excel_file_reader = double('excel_file_reader')
    allow(ExcelFileReader).to receive(:new).and_return(@excel_file_reader)
    @excel_content = []
    allow(@excel_file_reader).to receive(:read).and_return(@excel_content)
    @parseable_data = []
    allow(CommentsDataParser).to receive(:convert_to_parseable_data).and_return(@parseable_data)
    @parsed_data = {}
    allow(CommentsDataParser).to receive(:parse).and_return(@parsed_data)
    allow(CommentsDataParser).to receive(:store)
  end

  it 'processes a file of comments' do
    @comments[0].url = 'http://www.example.com/file.xlsx'

    @comments[0].process

    expect(@excel_file_reader).to have_received(:read).with(@comments[0].url)
    expect(CommentsDataParser).to have_received(:convert_to_parseable_data).with(@excel_content)
    expect(CommentsDataParser).to have_received(:parse).with(@parseable_data)
    expect(CommentsDataParser).to have_received(:store).with(@parsed_data)
  end
end 
