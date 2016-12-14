class MessageTemplateImporter < Importer
  def post_initialize
    self.import_class = MessageTemplate
    self.column_index_attribute_mapping = { 0 => 'content', 1 => 'platform', 2 => 'hashtags', 3 => 'tag_list' }
  end

  def post_import(parsed_csv_content)
    # After importing the message templates, import the associated websites.
    # When importing message templates, for convenience, the CSV file also contains website_url and website_name columns (column indexes 4 and 5).
    # The data for the websites is pulled out and passed to a WebsiteImporter instance along with the tag_list in the order that WebsiteImporter expects.
    websites_parsed_csv_content = []
    parsed_csv_content.each.with_index do |csv_row, index|
      websites_parsed_csv_content << nil if index == 0 # Add a nil to represent the headin row.
      websites_parsed_csv_content << [csv_row[4], csv_row[5], csv_row[3]] if index != 0
    end
    website_importer = WebsiteImporter.new(websites_parsed_csv_content, experiment_tag)
    website_importer.import
  end
end