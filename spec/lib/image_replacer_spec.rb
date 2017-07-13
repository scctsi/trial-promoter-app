require 'rails_helper'

RSpec.describe ImageReplacer do
  before do
    @image_replacer = ImageReplacer.new
  end
  
  it 'can replace the images for TCORS' do
    create(:experiment)
    random_image_replacement_mapping = {1 => 2, [3, 4] => 3}
    allow(@image_replacer).to receive(:generate_random_image_replacement_mapping).and_return(random_image_replacement_mapping)
    allow(@image_replacer).to receive(:replace_using_mapping)
    
    @image_replacer.replace_images_for_tcors
    
    ids_of_images_to_replace = [260, 233, [149, 73], [142, 55], [134, 98], [120, 13], [119, 11], [118, 14], [116, 15], [115, 22], [112,16], [17, 113], [109, 18], [20, 111], [102, 31], [103, 28], [101, 30], [100, 99, 32], [97, 34], [72, 135], [71, 33], [29, 96], 6, 5, 3, 2]
    ids_of_replacement_images = [290, 291, 292, 293, 294, 295, 296, 297, 298, 299, 300, 301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 311, 312, 313, 314, 315]

    expect(@image_replacer).to have_received(:generate_random_image_replacement_mapping).with(ids_of_images_to_replace, ids_of_replacement_images)
    expect(@image_replacer).to have_received(:replace_using_mapping).with(random_image_replacement_mapping)
    modification = Modification.first
    expect(modification.experiment).to eq(Experiment.first)
    expect(modification.description).to eq('Replacement of copyrighted images')
    expect(modification.details).to eq(random_image_replacement_mapping.to_s)
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

    expect { @image_replacer.generate_random_image_replacement_mapping(ids_of_images_to_replace, ids_of_replacement_images) }.to raise_error(DuplicateImageToReplaceIdError)
  end
  
  it 'raises an error if any id in the ids of the replacement images are duplicated' do
    ids_of_images_to_replace = [[1, 3, 5], 2, [7, 8], 9, 19, 15]
    ids_of_replacement_images = [10, 11, 14, 16, 17, 10]

    expect { @image_replacer.generate_random_image_replacement_mapping(ids_of_images_to_replace, ids_of_replacement_images) }.to raise_error(DuplicateReplacementImageIdError)
  end

  it 'raises an error if there are not enough replacement images for the images to be replaced' do
    ids_of_images_to_replace = [[1, 3, 5], 2, [7, 8], 9, 19, 15]
    ids_of_replacement_images = [10, 11, 14, 16]

    expect { @image_replacer.generate_random_image_replacement_mapping(ids_of_images_to_replace, ids_of_replacement_images) }.to raise_error(NotEnoughReplacementImagesError)
  end

  describe 'replacing images' do
    before do
      @message = create(:message)
      @images = create_list(:image, 5)
      @message.image = @images[0]
      @message.save
    end
    
    it 'can replace all images given a simple (no images with identical content) image replacement mapping' do
      allow(@image_replacer).to receive(:replace_image)

      @image_replacer.replace_using_mapping({@images[0].id => @images[1].id, @images[2].id => @images[3].id})

      expect(@image_replacer).to have_received(:replace_image).with(@images[0], @images[1])
      expect(@image_replacer).to have_received(:replace_image).with(@images[2], @images[3])
    end

    it 'can replace all images given a complex (images with identical content) image replacement mapping' do
      allow(@image_replacer).to receive(:replace_image)

      @image_replacer.replace_using_mapping({[@images[0].id, @images[4].id] => @images[1].id, @images[2].id => @images[3].id})

      expect(@image_replacer).to have_received(:replace_image).with(@images[0], @images[1])
      expect(@image_replacer).to have_received(:replace_image).with(@images[4], @images[1])
      expect(@image_replacer).to have_received(:replace_image).with(@images[2], @images[3])
    end

    it 'can replace an image with another image across all messages' do
      messages = create_list(:message, 4)
      messages[0].image = @images[0]
      messages[1].image = @images[1]
      messages[2].image = @images[0]
      messages[3].image = @images[2]
      messages.each { |message| message.save }
      allow(@image_replacer).to receive(:replace)
      
      @image_replacer.replace_image(@images[0], @images[1])
  
      expect(@image_replacer).to have_received(:replace).with(messages[0], @images[1])
      expect(@image_replacer).not_to have_received(:replace).with(messages[1], @images[1])
      expect(@image_replacer).to have_received(:replace).with(messages[2], @images[1])
      expect(@image_replacer).not_to have_received(:replace).with(messages[3], @images[1])
    end

    it 'replaces an image for a message and logs the action at the same time' do
      @image_replacer.replace(@message, @images[1])
  
      @message.reload
      expect(@message.image).to eq(@images[1])
      expect(@message.image_replacements.count).to eq(1)
      image_replacement = @message.image_replacements[0]
      expect(image_replacement.message).to eq(@message)
      expect(image_replacement.previous_image).to eq(@images[0])
      expect(image_replacement.replacement_image).to eq(@images[1])
    end
  
    it 'does not replace an image if the message has already been sent to Buffer' do
      @message.buffer_update = create(:buffer_update)
      @message.save

      @image_replacer.replace(@message, @images[1])
  
      @message.reload
      expect(@message.image).to eq(@images[0])
      expect(@message.image_replacements.count).to eq(0)
    end    
  end
end