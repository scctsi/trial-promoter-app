require 'rails_helper'

RSpec.describe ImagePoolManager do
  before do
    @image_pool_manager = ImagePoolManager.new
    @message_templates = create_list(:message_template, 3)
    @images = create_list(:image, 5)
    @experiments = create_list(:experiment, 2)
    @images[0..2].each do |image| 
      image.experiment_list = @experiments[0].to_param
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
end