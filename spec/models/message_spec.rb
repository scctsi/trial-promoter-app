require 'rails_helper'

describe Message do
  it { is_expected.to validate_presence_of(:content) }
  it { is_expected.to validate_presence_of(:campaign) }
  it { is_expected.to validate_presence_of(:medium) }

  # Source - Platform
  # Medium - Ad, Organic
  # Campaign - Trial Promoter Staging or Trial Promoter

  it { is_expected.to belong_to :clinical_trial }
  it { is_expected.to belong_to :message_template }

  it 'saves the content as a string' do
    message = Message.new(:campaign => 'trial-promoter', :medium => 'paid', :content => 'Some content')

    message.save
    message.reload

    expect(message.content).to eq('Some content')
  end

  it 'saves the content as an array (used for Google, YouTube ads)' do
    message = Message.new(:campaign => 'trial-promoter', :medium => 'paid', :content => ['Headline', 'Description Line 1', 'Description Line 2'])

    message.save
    message.reload

    expect(message.content).to eq(['Headline', 'Description Line 1', 'Description Line 2'])
  end

  it 'gets the permanent_image_url from a thumbnail URL (hosted on Dropbox)' do
    message = Message.new(:thumbnail_url => 'https://api-content.dropbox.com/r11/t/AAANnP_XPBxb28PEfpYSoSap92axlFNxaN4CT4G1i5SKNA/12/307720262/png/_/0/4/children_1.png/CMbg3ZIBIAEgAiADIAQgBSAGIAcoAigH/ps2uob5dswyejiz/AADF_c9_6efgbktZAVxuxLDia/children_1.png?bounding_box=256&mode=fit')

    expect(message.permanent_image_url).to eq('http://sc-ctsi.org/trial_promoter/image_pool/children_1.png')
  end

  it 'returns the same permanent_image_url as the image_url if the image is hosted on SC CTSI' do
    message = Message.new(:image_url => 'http://sc-ctsi.org/trial_promoter/image_pool/rope.png', :thumbnail_url => 'http://sc-ctsi.org/trial_promoter/image_pool/rope_thumbnail.png')

    expect(message.permanent_image_url).to eq('http://sc-ctsi.org/trial_promoter/image_pool/rope.png')
  end
end
