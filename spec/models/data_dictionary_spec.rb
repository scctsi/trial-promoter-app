require 'rails_helper'

RSpec.describe DataDictionary do
  it { is_expected.to have_many :data_dictionary_entries }
  it { is_expected.to belong_to :experiment }
  it { is_expected.to validate_presence_of :experiment }

  it 'has a pre-defined hash of data elements (key is the source, value is an array of trial promoter labels)' do
    data_elements = DataDictionary::DATA_ELEMENTS
    
    expect(data_elements[:trial_promoter]).to eq(['ordinal_day, date_set, day_of_week_sent, time_sent, platform, medium, image_used, tags, link_clicks, click_time'])
    expect(data_elements[:twitter]).to eq(['impressions, retweets, replies, likes'])
    expect(data_elements[:facebook]).to eq(['impressions, shares, comments, likes'])
    expect(data_elements[:instagram]).to eq(['impressions, reposts, comments, likes'])
  end
  
  # it 'can create a blank dictionary for an experiment' do
  #   experiment = create(:experiment)
    
  #   DataDictionary.create_blank_dictionary(experiment)
    
    
  # end
end
