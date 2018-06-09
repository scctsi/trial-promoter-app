# == Schema Information
#
# Table name: comments
#
#  id                      :integer          not null, primary key
#  comment_date            :datetime
#  comment_text            :text
#  commentator_username    :text
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  toxicity_score          :string
#  message_id              :integer
#  social_media_comment_id :string
#  commentator_id          :string
#

require 'rails_helper'

describe Comment do
  it { is_expected.to belong_to :message }

  describe "GET #sync_with_buffer (development only tests)", :development_only_tests => true do 
    before do
      @experiment = build(:experiment)
      secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
      @experiment.set_api_key('google_perspective', secrets['google_perspective_api_key'])
      @messages = create_list(:message, 6, :platform => :facebook, :publish_status => :published_to_social_network)
      @messages.each{|message| message.buffer_update = create(:buffer_update)}
      @messages[0].buffer_update.published_text = "#Tobacco use causes 1300 US deaths daily-more than AIDS, alcohol, car accidents, homicides & illegal drugs combined http://bit.ly/2pyWcHR"
      @messages[1].buffer_update.published_text = "#Smoking damages your DNA, which can cause cancer almost anywhere, not just your lungs. http://bit.ly/2oKGOYW"
      @messages[2].buffer_update.published_text = ""
      @messages[4].buffer_update.published_text = "Hydrogen cyanide is found in rat poison. It’s also in #cigarette smoke.  
      
      http://bit.ly/2t2KVBd"
      @messages[5].buffer_update.published_text = "Over 100 million non-smokers in this country are exposed to toxic secondhand smoke. http://bit.ly/2qrdtTT #smoking"  
      @messages.each{ |message| message.buffer_update.save }
      @messages[3].buffer_update =nil
      @messages[3].save
      @filepath = "#{Rails.root}/spec/fixtures/facebook_comments2.xlsx"
    end 
  
    it 'processes a file of comments' do
      Comment.process(@filepath)
      
      expect(@messages[0].comments.count).to eq(1)
      expect(@messages[1].comments.count).to eq(2)
      expect(@messages[2].comments.count).to eq(0)
      expect(@messages[5].comments.count).to eq(1)
    end
    
    it 'does not save duplicate comments' do
      Comment.process(@filepath)
      Comment.process(@filepath)
  
      expect(@messages[0].comments.count).to eq(1)
      expect(@messages[1].comments.count).to eq(2)
      expect(@messages[2].comments.count).to eq(0)   
      expect(@messages[3].comments.count).to eq(0)
      expect(@messages[4].comments.count).to eq(1)    
      expect(@messages[4].comments.first.comment_text).to eq("Very gross")    
    end 
    
    it 'saves the toxicity_score to the comment' do
      comment = create(:comment)
      
      allow(PerspectiveClient).to receive(:calculate_toxicity_score).and_return("0.78")
      comment.save_toxicity_score(@experiment)
  
      comment.reload
      expect(comment.toxicity_score).to eq("0.78")
    end
    
    it 'skips the api call if a toxicity_score already exists' do
      allow(PerspectiveClient).to receive(:calculate_toxicity_score).and_return("0.78")
      comment = create(:comment)
      
      comment.save_toxicity_score(@experiment)
      comment.save_toxicity_score(@experiment)
      
      expect(PerspectiveClient).to have_received(:calculate_toxicity_score).once
    end
  end  
end  
