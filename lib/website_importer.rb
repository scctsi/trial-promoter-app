class WebsiteImporter < Importer
  COLUMN_INDEX_ATTRIBUTE_MAPPING = { 0 => 'name', 1 => 'url', 2 => 'tag_list' }

  def import(parsed_csv_content, experiment_tag = '')
    super(Website, parsed_csv_content, COLUMN_INDEX_ATTRIBUTE_MAPPING, experiment_tag)
  end
end