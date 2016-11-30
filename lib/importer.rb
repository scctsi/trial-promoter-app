class Importer
  COLUMN_INDEX_ATTRIBUTE_MAPPINGS = { MessageTemplate => { 0 => 'content', 1 => 'platform', 2 => 'tag_list', 3 => 'hashtags' },
                                      Image => { 0 => 'url', 1 => 'original_filename', 2 => 'tag_list' },
                                      Website => { 0 => 'name', 1 => 'url', 2 => 'tag_list' }
                                    }
  
  def import(klass, parsed_csv_content, additional_tag = '')
    # Image imports are a special case. What is passed into parsed_csv_content is an array of uploaded image URLs.
    # The next block of code basically fixes parsed_csv_content so that the code remains the same for uploading images.
    # To do this, we need to convert ['url1', 'url2'] to [nil, ['url1', 'N/A', 'additional_tag'], ['url2', 'N/A', 'additional_tag']]
    if klass == Image
      parsed_csv_content = parsed_csv_content.dup
      parsed_csv_content.unshift(nil)
      parsed_csv_content = parsed_csv_content.map { |url| [url, 'N/A', "#{additional_tag}"] }
    end
    
    # Remove the heading row for the parsed_csv_content
    parsed_csv_content = parsed_csv_content.drop(1)

    parsed_csv_content.each do |row|
      column_index_attribute_mapping = COLUMN_INDEX_ATTRIBUTE_MAPPINGS[klass]
      attributes = {}
      
      row.each.with_index do |value, i|
        attributes[column_index_attribute_mapping[i]] = row[i]
        # Experiments and campaigns can generate messages. They are message generating classes.
        # We usually import message templates, images etc. for use by a specific message generating instance.
        # Imported instances are tied to the parent message generating instance by adding a tag that is equal to the parameterized slug for the message generating instance.
        if column_index_attribute_mapping[i] == 'tag_list' && !additional_tag.blank?
          attributes[column_index_attribute_mapping[i]] = "#{attributes[column_index_attribute_mapping[i]]}, #{additional_tag}"
        end
      end
      
      create(klass, attributes)
    end
  end
  
  def create(klass, attributes)
    return klass.create!(attributes)
  end
end