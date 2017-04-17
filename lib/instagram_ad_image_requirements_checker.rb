class InstagramAdImageRequirementsChecker
  def self.set_image_sizes
    Image.all.each do |image|
      next if !(image.width.nil?) && !(image.height.nil?)
      image_size = FastImage.size(image.url, :raise_on_failure => false, :timeout => 2.0)
      if image_size.nil?
        image.width = nil
        image.height = nil
        image.save
      else
        image.width = image_size[0]
        image.height = image_size[1]
        image.save
      end
      Throttler.throttle(1)
    end
  end
  
  def self.check_image_sizes
    Image.all.each do |image|
      image.meets_instagram_ad_requirements = valid_image_size?(image)
      image.save
    end
  end
  
  def self.valid_image_size?(image)
    return nil if image.width.nil? || image.height.nil?
    
    # Landscape images
    if image.width > image.height
      return false if image.width < 600 || image.height < 315
    end

    # Vertical images
    if image.width < image.height
      return false if image.width < 600 || image.height < 750
    end
    
    # Square images
    if image.width == image.height
      return false if image.width < 600
    end

    true
  end
end
