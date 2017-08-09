require 'rails_helper'

RSpec.describe ImagePoolManager do
  before do
    @image_pool_manager = ImagePoolManager.new
    @message_templates = create_list(:message_template, 3)
    @images = create_list(:image, 5)
    @experiments = create_list(:experiment, 2)
    @images[0..2].each.with_index do |image, index|
      image.experiment_list = @experiments[0].to_param
      image.original_filename = "filename_#{index}.png"
      image.save 
    end
    # Give two other images belonging to another experiment duplicate filenames 
    @images[3..4].each.with_index do |image, index|
      image.experiment_list = @experiments[1].to_param
      image.original_filename = "filename_#{index}.png"
      image.save 
    end
  end

  it 'adds a single image to the image pool for a message template given a single id' do
    @image_pool_manager.add_images(@images[0].id, @message_templates[1])
    
    @message_templates[1].reload
    expect(@message_templates[1].image_pool).to eq([@images[0].id])
  end

  it 'adds a single image to the image pool for a message template given a single id as a string' do
    @image_pool_manager.add_images(@images[0].id, @message_templates[1])
    
    @message_templates[1].reload
    expect(@message_templates[1].image_pool).to eq([@images[0].id])
  end
  
  it 'adds multiple images to the image pool for a message template given multiple image ids' do
    @image_pool_manager.add_images([@images[0].id, @images[1].id], @message_templates[1])
    
    @message_templates[1].reload
    expect(@message_templates[1].image_pool).to eq([@images[0].id, @images[1].id])
  end

  it 'only adds unique images to the image pool for a message template given multiple image ids' do
    @image_pool_manager.add_images([@images[0].id, @images[0].id, @images[1].id], @message_templates[1])
    
    @message_templates[1].reload
    expect(@message_templates[1].image_pool).to eq([@images[0].id, @images[1].id])
  end

  it 'does not adds duplicate images to the image pool for a message template given image ids' do
    @image_pool_manager.add_images([@images[0].id, @images[1].id], @message_templates[1])
    @image_pool_manager.add_images([@images[0].id, @images[1].id], @message_templates[1])
    
    @message_templates[1].reload
    expect(@message_templates[1].image_pool).to eq([@images[0].id, @images[1].id])
  end

  it 'adds a new image to an existing image pool' do
    @image_pool_manager.add_images([@images[0].id, @images[1].id], @message_templates[1])
    @image_pool_manager.add_images(@images[2].id, @message_templates[1])
    
    @message_templates[1].reload
    expect(@message_templates[1].image_pool).to eq([@images[0].id, @images[1].id, @images[2].id])
  end

  it 'adds multiple images to an existing image pool' do
    @image_pool_manager.add_images(@images[0].id, @message_templates[1])
    @image_pool_manager.add_images([@images[1].id, @images[2].id], @message_templates[1])
    
    @message_templates[1].reload
    expect(@message_templates[1].image_pool).to eq([@images[0].id, @images[1].id, @images[2].id])
  end

  it 'has a method to return the number of remaining images when removing multiple images from the pool' do
    @image_pool_manager.add_images([@images[0].id, @images[1].id, @images[2].id], @message_templates[1])
    
    remaining_images_count = @image_pool_manager.remaining_images_count([@images[0].id, @images[2].id], @message_templates[1])
    
    expect(remaining_images_count).to eq(1)
  end

  it 'returns the number of remaining images when given a large set of images to remove, some of which are not in the pool' do
    @image_pool_manager.add_images([@images[0].id, @images[1].id, @images[2].id], @message_templates[1])
    
    remaining_images_count = @image_pool_manager.remaining_images_count([@images[0].id, @images[2].id, @images[3].id], @message_templates[1])
    
    expect(remaining_images_count).to eq(1)
  end
  
  it 'can store a set of images to remove and use that by default for the remaining_images_count method' do
    @image_pool_manager.add_images([@images[0].id, @images[1].id, @images[2].id], @message_templates[1])
    
    @image_pool_manager.set_of_images_to_remove = [@images[0].id, @images[2].id, @images[3].id]
    remaining_images_count = @image_pool_manager.remaining_images_count(@message_templates[1])
        
    expect(remaining_images_count).to eq(1)
  end

  it 'removes a single image from an existing image pool' do
    @image_pool_manager.add_images([@images[0].id, @images[1].id], @message_templates[1])

    @image_pool_manager.remove_image(@images[0].id, @message_templates[1])

    @message_templates[1].reload
    expect(@message_templates[1].image_pool).to eq([@images[1].id])
  end
  
  it 'removes a single image from an existing image pool with the image id passed in as a string' do
    @image_pool_manager.add_images([@images[0].id, @images[1].id], @message_templates[1])

    @image_pool_manager.remove_image(@images[0].id.to_s, @message_templates[1])

    @message_templates[1].reload
    expect(@message_templates[1].image_pool).to eq([@images[1].id])
  end

  it 'removes multiple images from an existing image pool' do
    @image_pool_manager.add_images([@images[0].id, @images[1].id, @images[2].id], @message_templates[1])

    @image_pool_manager.remove_images([@images[0].id, @images[2].id], @message_templates[1])

    @message_templates[1].reload
    expect(@message_templates[1].image_pool).to match_array([@images[1].id])
  end

  it 'can store a set of images to remove and use that by default for the remove_images method' do
    @image_pool_manager.add_images([@images[0].id, @images[1].id, @images[2].id], @message_templates[1])
    
    @image_pool_manager.set_of_images_to_remove = [@images[0].id, @images[2].id, @images[3].id]
    @image_pool_manager.remove_images(@message_templates[1])

    @message_templates[1].reload
    expect(@message_templates[1].image_pool).to match_array([@images[1].id])
  end
  
  it 'returns all selected and unselected images for a message template' do
    @image_pool_manager.add_images([@images[0].id, @images[1].id], @message_templates[1])

    selected_and_unselected_images = @image_pool_manager.get_selected_and_unselected_images(@experiments[0], @message_templates[1])

    expect(selected_and_unselected_images[:selected_images].count).to eq(2)
    selected_and_unselected_images[:selected_images].each do |image|
      expect(@message_templates[1].image_pool).to include(image.id)
    end
    expect(selected_and_unselected_images[:unselected_images].count).to eq(1)
    selected_and_unselected_images[:unselected_images].each do |image|
      expect(@message_templates[1].image_pool).not_to include(image.id)
    end
  end
  
  it 'adds images to a image pool given a comma-separated list of image filenames' do
    @image_pool_manager.add_images_by_filename(@experiments[0].to_param, [@images[0].original_filename, @images[1].original_filename], @message_templates[1])

    @message_templates[1].reload
    expect(@message_templates[1].image_pool).to match_array([@images[0].id, @images[1].id])
  end
end