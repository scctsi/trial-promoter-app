class ImageImporter < Importer
  COLUMN_INDEX_ATTRIBUTE_MAPPING = { 0 => 'url', 1 => 'original_filename', 2 => 'tag_list' }

  def import(image_urls, experiment_tag = '')
    # When importing images, this method only received an array of hosted image URLs.
    # The base method expects an array of rows with data for each column, along with a first row that is nil for the heading.
    # Example: ['url1', 'url2'] needs to be converted to [nil, ['url1', 'N/A'], ['url2', 'N/A']]
    parsed_csv_content = image_urls.dup
    parsed_csv_content.unshift(nil) # Add a nil first row for the heading row that is ignored.
    parsed_csv_content = parsed_csv_content.map { |url| [url, 'N/A'] } # Set the original_filename to N/A for all images

    super(Image, parsed_csv_content, COLUMN_INDEX_ATTRIBUTE_MAPPING, experiment_tag)
  end
end