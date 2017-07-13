require 'rails_helper'

RSpec.describe ImageReplacer do
  before do
    @image_replacer = ImageReplacer.new
  end
  
  it 'can generate a replacement mapping for images' do
    ids_of_images_to_replace = [1, 2, 3, 5, 6, 7]     
    ids_of_replacement_images = [10, 11, 14, 16, 17, 28]
    shuffled_ids_of_replacement_images = [11, 10, 28, 16, 17, 14]
    allow(ids_of_replacement_images).to receive(:shuffle).and_return(shuffled_ids_of_replacement_images)
    
    image_replacement_mapping = @image_replacer.generate_random_image_replacement_mapping(ids_of_images_to_replace, ids_of_replacement_images)
    
    expect(image_replacement_mapping.keys.count).to eq(ids_of_images_to_replace.count)
    expect(image_replacement_mapping.values.count).to eq(ids_of_replacement_images.count)
    expect(image_replacement_mapping.values).to eq(shuffled_ids_of_replacement_images)
  end

  it 'can generate a replacement mapping for images, even when the images to replace have multiple ids (indicating that multiple images need replacement)' do
    ids_of_images_to_replace = [[1, 3, 5], 2, [6, 7], 8, 9, 11]
    ids_of_replacement_images = [10, 11, 14, 16, 17, 28]
    shuffled_ids_of_replacement_images = [11, 10, 28, 16, 17, 14]
    allow(ids_of_replacement_images).to receive(:shuffle).and_return(shuffled_ids_of_replacement_images)
    
    image_replacement_mapping = @image_replacer.generate_random_image_replacement_mapping(ids_of_images_to_replace, ids_of_replacement_images)
    
    expect(image_replacement_mapping.keys.count).to eq(ids_of_images_to_replace.count)
    expect(image_replacement_mapping.values.count).to eq(ids_of_replacement_images.count)
    expect(image_replacement_mapping.values).to eq(shuffled_ids_of_replacement_images)
  end
  
  it 'raises an error if any id in the ids of the images to replace are duplicated' do
    ids_of_images_to_replace = [[1, 3, 5], 2, [3, 7], 8, 9, 5]
    ids_of_replacement_images = [10, 11, 14, 16, 17, 28]

    expect { image_replacement_mapping = @image_replacer.generate_random_image_replacement_mapping(ids_of_images_to_replace, ids_of_replacement_images) }.to raise_error(DuplicateImageToReplaceIdError)
  end
  
  it 'raises an error if any id in the ids of the replacement images are duplicated' do
    ids_of_images_to_replace = [[1, 3, 5], 2, [7, 8], 9, 19, 15]
    ids_of_replacement_images = [10, 11, 14, 16, 17, 10]

    expect { image_replacement_mapping = @image_replacer.generate_random_image_replacement_mapping(ids_of_images_to_replace, ids_of_replacement_images) }.to raise_error(DuplicateReplacementImageIdError)
  end

  it 'raises an error if there are not enough replacement images for the images to be replaced' do
    ids_of_images_to_replace = [[1, 3, 5], 2, [7, 8], 9, 19, 15]
    ids_of_replacement_images = [10, 11, 14, 16]

    expect { image_replacement_mapping = @image_replacer.generate_random_image_replacement_mapping(ids_of_images_to_replace, ids_of_replacement_images) }.to raise_error(NotEnoughReplacementImagesError)
  end
end