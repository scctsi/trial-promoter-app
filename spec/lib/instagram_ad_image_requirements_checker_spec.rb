require 'rails_helper'

RSpec.describe InstagramAdImageRequirementsChecker do
  before do 
    @images = create_list(:image, 3)
    allow(FastImage).to receive(:size).with(an_instance_of(String), :raise_on_failure => false, :timeout => 2.0).and_return([100, 200])
    allow(Throttler).to receive(:throttle)
  end
  
  it 'sets the image size of all images' do
    InstagramAdImageRequirementsChecker.set_image_sizes
    
    @images.each do |image|
      expect(FastImage).to have_received(:size).with(image.url, :raise_on_failure => false, :timeout => 2.0)
      image.reload
      expect(image.width).to eq(100)
      expect(image.height).to eq(200)
    end
    expect(Throttler).to have_received(:throttle).with(1).exactly(@images.count).times
  end

  it 'ignores images whose size has already been set' do
    @images[0].width = 100
    @images[0].height = 200
    @images[0].save
    @images[2].width = 100
    @images[2].height = 200
    @images[2].save
    
    InstagramAdImageRequirementsChecker.set_image_sizes

    expect(FastImage).not_to have_received(:size).with(@images[0].url, :raise_on_failure => false, :timeout => 2.0)
    expect(FastImage).to have_received(:size).with(@images[1].url, :raise_on_failure => false, :timeout => 2.0)
    expect(FastImage).not_to have_received(:size).with(@images[2].url, :raise_on_failure => false, :timeout => 2.0)
  end

  it 'ignores images for which FastImage cannot get the size' do
    allow(FastImage).to receive(:size).with(an_instance_of(String), :raise_on_failure => false, :timeout => 2.0).and_return(nil)
    InstagramAdImageRequirementsChecker.set_image_sizes
    
    @images.each do |image|
      image.reload
      expect(image.width).to be nil
      expect(image.height).to be nil
    end
    expect(Throttler).to have_received(:throttle).with(1).exactly(@images.count).times
  end

  it 'checks the validity of all images' do
    allow(InstagramAdImageRequirementsChecker).to receive(:valid_image_size?).with(@images[0]).and_return(true)
    allow(InstagramAdImageRequirementsChecker).to receive(:valid_image_size?).with(@images[1]).and_return(false)
    allow(InstagramAdImageRequirementsChecker).to receive(:valid_image_size?).with(@images[2]).and_return(nil)

    InstagramAdImageRequirementsChecker.check_image_sizes
    
    @images.each do |image|
      image.reload
    end
    expect(@images[0].meets_instagram_ad_requirements).to be true
    expect(@images[1].meets_instagram_ad_requirements).to be false
    expect(@images[2].meets_instagram_ad_requirements).to be nil
  end
  
  describe 'checking whether the image meets the requirements for Instagram ads' do
    # Minimum resolution: 600x315 pixels (1.91:1 landscape)/600x600 pixels (1:1 square)/600x750 pixels (4:5 vertical)
    before do
      @image = build(:image)
    end
    
    it 'returns nil for any image with a nil width' do
      @image.width = nil
      @image.height = 315
      
      expect(InstagramAdImageRequirementsChecker.valid_image_size?(@image)).to be nil
    end

    it 'returns nil for any image with a nil height' do
      @image.width = 600
      @image.height = nil
      
      expect(InstagramAdImageRequirementsChecker.valid_image_size?(@image)).to be nil
    end

    it 'returns nil for any image with a nil height and nil width' do
      @image.width = nil
      @image.height = nil
      
      expect(InstagramAdImageRequirementsChecker.valid_image_size?(@image)).to be nil
    end

    it 'meets the minimum width for landscape images' do
      @image.width = 500
      @image.height = 315
      
      expect(InstagramAdImageRequirementsChecker.valid_image_size?(@image)).to be false
    end

    it 'meets the minimum height for landscape images' do
      @image.width = 600
      @image.height = 215
      
      expect(InstagramAdImageRequirementsChecker.valid_image_size?(@image)).to be false
    end

    it 'meets the minimum height for square images' do
      @image.width = 500
      @image.height = 500
      
      expect(InstagramAdImageRequirementsChecker.valid_image_size?(@image)).to be false
    end

    it 'meets the minimum width for vertical images' do
      @image.width = 600
      @image.height = 715
      
      expect(InstagramAdImageRequirementsChecker.valid_image_size?(@image)).to be false
    end

    it 'meets the minimum height for vertical images' do
      @image.width = 500
      @image.height = 750

      expect(InstagramAdImageRequirementsChecker.valid_image_size?(@image)).to be false
    end
  end
end