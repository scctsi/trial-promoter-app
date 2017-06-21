require 'rails_helper'

RSpec.describe CampaignMatcher do
  before do
    @messages = create_list(:message, 4)
    @messages[0].content= 'Nicotine is highly addictive. Every day in the US 700+ youth become daily smokers. http://bit.ly/2sQgHRk #cigs'
    @messages[1].content = '#Smoking damages DNA, which can lead to cancer almost anywhere in the body. http://bit.ly/2sQgHRk #cigs'
    @messages[2].content= 'Every day in the US 700+ youth become daily smokers. Nicotine is highly addictive. http://bit.ly/2sQgHRk #cigs'

    (0..2).each{ |index| @messages[index].platform = 'facebook' }
    @messages[3].platform = 'instagram'

    @messages.each{ |message| message.publish_status = 'published_to_social_network' }

    @messages.each{ |message| message.save }

    @campaigns = []
    (0..6).each { |index| @campaigns[index] = OpenStruct.new }
    @campaigns[0].name = 'Post: "Nicotine is highly addictive. Every day in the US..."'
    @campaigns[0].id = '6074485202639'
    @campaigns[0].start_date ="5/9/2016"

    @campaigns[1].name = 'Post: "Every day in the US 700+ youth become daily smokers. Nicotine is highly addictive..."'
    @campaigns[1].id = '3074485264939'
    @campaigns[1].start_date ="5/9/2016"

    @campaigns[2].name = 'Post: "Every day in the US 700+ youth become daily smokers..."'
    @campaigns[2].id = '3075555264933'
    @campaigns[2].start_date ="5/9/2016"

    @campaigns[3].name = 'Post: "Every day in the US 700+ youth become daily smokers..."'
    @campaigns[3].id = '4075555364933'
    @campaigns[3].start_date ="5/9/2016"

    @campaigns[4].name = 'Post: "Every day in the US 700+ youth become daily smokers..."'
    @campaigns[4].id = '5075555464935'
    @campaigns[4].start_date ="5/9/2016"

    @campaigns[5].name = 'Post: "Every day in the US 800+ youth become daily smokers..."'
    @campaigns[5].id = '4075555364933'
    @campaigns[5].start_date ="5/9/2016"

    @campaigns[6].name = 'Post: "Every day in the US 800+ youth become daily smokers..."'
    @campaigns[6].id = '5075555464935'
    @campaigns[6].start_date ="5/9/2016"

  end

  describe '#match_campaign_id' do
    it 'assigns the matching campaign id to the original message using the ad name (truncated post message) and returns duplicate messages to be assigned manually' do
      rejects = CampaignMatcher.match_campaign_id(@messages, @campaigns)

      @messages.each{ |message| message.reload }

      expect(@messages[0].campaign_id).to eq(@campaigns[0].id)
      expect(@messages[1].campaign_id).to eq(nil)
      expect(@messages[2].campaign_id).to eq(@campaigns[1].id)
      expect(@messages[3].campaign_id).to eq(nil)
      expect(rejects.count).to eq(2)
      expect(rejects[0][0].name).to eq('Post: "Every day in the US 700+ youth become daily smokers..."')
    end
  end

  describe '#clean_ad_name' do
    it 'removes the extra characters from the campaign name analytics file' do
      expect(clean_ad_name(@campaigns[0].name)).to eq("Nicotine is highly addictive. Every day in the US")
    end
  end

  describe '#set_unmatchable' do
    it 'checks message for nil campaign id and sets the campaign_unmatchable to true' do
      @messages[2].campaign_id = @campaigns[1].id

      set_unmatchable(@messages[2])
      set_unmatchable(@messages[3])

      expect(@messages[2].campaign_unmatchable).to eq(false)
      expect(@messages[3].campaign_unmatchable).to eq(true)
    end
  end

  describe '#instagram?' do
    it 'checks for instagram and sets the campaign_unmatchable to true' do
      expect(instagram?(@messages[0])).to eq(false)
      expect(instagram?(@messages[3])).to eq(true)
    end
  end
end