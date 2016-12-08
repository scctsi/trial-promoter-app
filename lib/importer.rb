class Importer
  # TODO: This class is only unit tested via its subclasses.
  def import(klass, parsed_csv_content, column_index_attribute_mapping, experiment_tag = '')
    # Remove the heading row for the parsed_csv_content
    parsed_csv_content = parsed_csv_content.drop(1)

    parsed_csv_content.each do |row|
      attributes = {}
      
      row.each.with_index do |value, i|
        attributes[column_index_attribute_mapping[i]] = row[i] if column_index_attribute_mapping.has_key?(i)

        # Experiments and campaigns can generate messages. These are message generating classes.
        # We usually import message templates, images etc. for use by a specific message generating instance.
        # Imported instances are tied to the parent message generating instance by adding a tag to the experiments context that is equal to the parameterized slug for the message generating instance.
        attributes['experiment_list'] = experiment_tag if !experiment_tag.blank?
      end
      
      create(klass, attributes)
    end
  end
  
  def create(klass, attributes)
    return klass.create!(attributes)
  end
end