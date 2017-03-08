class WebsiteImporter < Importer
  def post_initialize
    self.import_class = Website
    self.column_index_attribute_mapping = { 0 => 'url', 1 => 'name', 2 => 'tag_list' }
  end
end