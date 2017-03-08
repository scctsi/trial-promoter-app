class ImagePoolManager
  def add_images(image_ids, message_template)
    image_ids = [image_ids] if image_ids.is_a?(Fixnum)
    image_ids = [image_ids.to_i] if image_ids.is_a?(String)
    message_template.image_pool = message_template.image_pool.concat(image_ids).uniq
    message_template.save
  end
  
  def remove_image(image_id, message_template)
    image_id = image_id.to_i
    message_template.image_pool.delete(image_id)
    message_template.save
  end
  
  def add_images_by_filename(experiment, original_filenames, message_template)
    image_ids = Image.belonging_to(experiment).where('original_filename in (?)', original_filenames).map(&:id).to_a
    
    add_images(image_ids, message_template)
  end
  
  def get_selected_and_unselected_images(experiment, message_template)
    selected_and_unselected_images = {}
    all_images = Image.belonging_to(experiment)
    
    selected_and_unselected_images[:selected_images] = all_images.select{ |image| message_template.image_pool.include?(image.id) }
    selected_and_unselected_images[:unselected_images] = all_images.select{ |image| !message_template.image_pool.include?(image.id) }
    
    selected_and_unselected_images
  end
end