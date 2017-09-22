# == Schema Information
#
# Table name: comments
#
#  id                   :integer          not null, primary key
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
    @messages = create_list(:message, 3, :platform => :facebook)
    @messages[0].content = "#Tobacco use causes 1300 US deaths daily-more than AIDS, alcohol, car accidents, homicides & illegal drugs combined http://bit.ly/2pyWcHR"
    @messages[1].content = "#Smoking damages your DNA, which can cause cancer almost anywhere, not just your lungs. http://bit.ly/2oKGOYW"
    @messages[2].content = ""
    @comment = create(:comment)
    @messages.each{ |message| message.save }
    @filename = "#{Rails.root}/spec/fixtures/sample_comments.xlsx"
  end

  it 'processes a file of comments' do

    @comment.process(@filename)
    expect(@messages[0].comments.count).to eq(1)
    expect(@messages[1].comments.count).to eq(2)
    expect(@messages[2].comments.count).to eq(0)
  end
  
  it 'does not save duplicate comments' do
    @comment.process(@filename)
    @comment.process(@filename)

    
    expect(@messages[0].comments.count).to eq(1)
    expect(@messages[1].comments.count).to eq(2)
    expect(@messages[2].comments.count).to eq(0)    
  end
end 
