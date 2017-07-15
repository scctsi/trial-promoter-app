class ImageReplacer
  def replace_images_for_tcors
    ids_of_images_to_replace = [260, 233, [149, 73], [142, 55], [134, 98], [120, 13], [119, 11], [118, 14], [116, 15], [115, 22], [112, 16], [17, 113], [109, 18], [20, 111], [102, 31], [103, 28], [101, 30], [100, 99, 32], [97, 34], [72, 135], [71, 33], [29, 96], 6, 5, 3, 2]
    ids_of_replacement_images = [290, 291, 292, 293, 294, 295, 296, 297, 298, 299, 300, 301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 311, 312, 313, 314, 315]

    image_replacement_mapping = generate_random_image_replacement_mapping(ids_of_images_to_replace, ids_of_replacement_images)
    replace_using_mapping(image_replacement_mapping)
    Modification.create!(:experiment => Experiment.first, :description => "Replacement of copyrighted images", :details => image_replacement_mapping)
  end

  def generate_random_image_replacement_mapping(ids_of_images_to_replace, ids_of_replacement_images)
    # Check if any of the ids_of_images_to_replace are duplicates. 
    # Each element of ids_of_images_to_replace can in turn be an array (to indicate multiple images whose content are the same).
    raise DuplicateImageToReplaceIdError if (ids_of_images_to_replace.flatten.count != ids_of_images_to_replace.flatten.uniq.count)

    # Check if any of the ids_of_replacement_images are duplicates. 
    raise DuplicateReplacementImageIdError if (ids_of_replacement_images.count != ids_of_replacement_images.uniq.count)
    
    # Check if there are enough replacement images provided 
    raise NotEnoughReplacementImagesError if (ids_of_replacement_images.count != ids_of_images_to_replace.count)

    random_image_replacement_mapping = {}
    
    shuffled_ids_of_replacement_images = ids_of_replacement_images.shuffle
    ids_of_images_to_replace.each.with_index do |id_of_image_to_replace, index| 
      random_image_replacement_mapping[id_of_image_to_replace] = shuffled_ids_of_replacement_images[index]
    end

    random_image_replacement_mapping
  end
  
  def replace(message, image)
    # Do not replace any images that have already been sent to Buffer
    return if !message.buffer_update.nil?
    
    previous_image = message.image
    replacement_image = image
    
    message.image = replacement_image
    message.save
    
    message.image_replacements.create(message: message, previous_image: previous_image, replacement_image: replacement_image)
  end
  
  def replace_image(previous_image, replacement_image)
    messages_with_previous_image = Message.joins(:image).where(:images => { :id => previous_image.id })
    messages_with_previous_image.each do |message_with_previous_image|
      replace(message_with_previous_image, replacement_image)
    end
  end
  
  def replace_using_mapping(image_replacement_mapping)
    image_replacement_mapping.each do |ids_of_image_to_replace, id_of_replacement_image|
      if ids_of_image_to_replace.is_a?(Fixnum)
        replace_image(Image.find(ids_of_image_to_replace), Image.find(id_of_replacement_image))
      else
        ids_of_image_to_replace.each do |id_of_image_to_replace|
          replace_image(Image.find(id_of_image_to_replace), Image.find(id_of_replacement_image))
        end
      end
    end
  end
end