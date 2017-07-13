class ImageReplacer
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
    ids_of_replacement_images.shuffle
    
    random_image_replacement_mapping
  end
end