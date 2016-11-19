class Importer
  COLUMN_INDEX_ATTRIBUTE_MAPPINGS = { MessageTemplate => {0 => 'content', 1 => 'platform', 2 => 'tag_list'} }
  
  def import(klass, parsed_csv_content)
    # Remove the heading row for the parsed_csv_content
    parsed_csv_content = parsed_csv_content.drop(1)

    parsed_csv_content.each do |row|
      column_index_attribute_mapping = COLUMN_INDEX_ATTRIBUTE_MAPPINGS[klass]
      attributes = {}
      
      row.each.with_index do |value, i|
        attributes[column_index_attribute_mapping[i]] = row[i]
      end
      
      create(klass, attributes)
    end
  end
  
  def create(klass, attributes)
    return klass.create!(attributes)
  end
end