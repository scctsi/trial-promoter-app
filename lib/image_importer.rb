class ImageImporter < Importer
  def pre_import_prepare(image_urls)
    # When importing images the initialize method receives an array of hosted image URLs.
    # The base method expects an array of rows with data for each column, along with a first row that is nil for the heading.
    # Example: ['url1', 'url2'] needs to be converted to [nil, ['url1', 'N/A'], ['url2', 'N/A']]
    parsed_csv_content = image_urls.dup
    parsed_csv_content.unshift(nil) # Add a nil first row for the heading row that is ignored.
    parsed_csv_content = parsed_csv_content.map { |url| [url, 'N/A'] } # Set the original_filename to N/A for all images

    parsed_csv_content
  end

  def post_initialize
    self.import_class = Image
    self.column_index_attribute_mapping = { 0 => 'url', 1 => 'original_filename', 2 => 'tag_list' }
  end
end