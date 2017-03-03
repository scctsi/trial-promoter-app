class ImageImporter < Importer
  def pre_import
    # Delete any previously associated images
    Image.tagged_with(@experiment_tag, on: :experiments).each{ |image| image.destroy }
  end

  def pre_import_prepare(image_urls_and_original_filenames)
    # When importing images the initialize method receives [array of hosted image URLs, array of original filenames].
    # The base method expects an array of rows with data for each column, along with a first row that is nil for the heading.
    # Example: ['url1', 'url2'] needs to be converted to [nil, ['url1', 'filename1'], ['url2', 'filename2']]
    image_urls = image_urls_and_original_filenames[0]
    original_filenames = image_urls_and_original_filenames[1]

    parsed_csv_content = []
    parsed_csv_content << [nil, nil] # Add a heading row into the content
    image_urls.each.with_index do |url, index|
      parsed_csv_content <<= [url, original_filenames[index]]
    end
    
    parsed_csv_content
  end

  def post_initialize
    self.import_class = Image
    self.column_index_attribute_mapping = { 0 => 'url', 1 => 'original_filename', 2 => 'tag_list' }
  end
end