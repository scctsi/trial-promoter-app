class Importer
  def import(klass, parsed_csv_content, column_index_attribute_mapping)
    # Remove the heading row for the parsed_csv_content
    parsed_csv_content = parsed_csv_content.drop(1)

    parsed_csv_content.each do |row|
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