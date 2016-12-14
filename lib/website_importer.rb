class WebsiteImporter < Importer
  def post_initialize
    self.import_class = Website
    self.column_index_attribute_mapping = { 0 => 'name', 1 => 'url', 2 => 'tag_list' }
  end
end