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
#

require 'rails_helper'

describe Comment do
  it { is_expected.to belong_to :message }

  before do
    @messages = create_list(:message, 4, :platform => :facebook)
    @messages.each{|message| message.buffer_update = create(:buffer_update)}
    @messages[0].buffer_update.published_text = "#Tobacco use causes 1300 US deaths daily-more than AIDS, alcohol, car accidents, homicides & illegal drugs combined http://bit.ly/2pyWcHR"
    @messages[1].buffer_update.published_text = "#Smoking damages your DNA, which can cause cancer almost anywhere, not just your lungs. http://bit.ly/2oKGOYW"
    @messages[2].buffer_update.published_text = ""
    @comment = create(:comment) 
    @messages.each{ |message| message.buffer_update.save }
    @messages[3].buffer_update =nil
    @messages[3].save
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
    expect(@messages[3].comments.count).to eq(0)    
  end 
  
  it 'saves the toxicity_score to the comment' do
    comment = create(:comment)
    
    allow(PerspectiveClient).to receive(:calculate_toxicity_score).and_return("0.78")
    comment.save_toxicity_score

    comment.reload
    expect(comment.toxicity_score).to eq("0.78")
  end
  
  it 'skips the api call if a toxicity_score already exists' do
    allow(PerspectiveClient).to receive(:calculate_toxicity_score).and_return("0.78")
    comment = create(:comment)
    
    comment.save_toxicity_score
    comment.save_toxicity_score
    
    expect(PerspectiveClient).to have_received(:calculate_toxicity_score).once
  end
end  
