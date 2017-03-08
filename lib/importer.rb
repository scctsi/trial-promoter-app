# TODO: This class is only unit tested via its subclasses.
class Importer
  attr_accessor :import_class, :parsed_csv_content, :column_index_attribute_mapping, :experiment_tag
  
  def initialize(parsed_csv_content, experiment_tag)
    self.parsed_csv_content = parsed_csv_content
    self.experiment_tag = experiment_tag
    
    post_initialize
  end
  
  def post_initialize
    self.import_class = nil
    self.column_index_attribute_mapping = {}
  end

  def pre_import
  end
  
  def pre_import_prepare(parsed_csv_content)
    # Always return a duplicate of the parsed_csv_content so that we can modify that content as needed without affecting the original.
    return parsed_csv_content.dup
  end
  
  def post_import(prepared_csv_content)
  end

  def import
    pre_import()
    prepared_csv_content = pre_import_prepare(parsed_csv_content)

    # Remove the heading row for the parsed_csv_content
    prepared_csv_content = prepared_csv_content.drop(1)

    prepared_csv_content.each do |row|
      attributes = {}
      
      row.each.with_index do |value, i|
        attributes[column_index_attribute_mapping[i]] = row[i] if column_index_attribute_mapping.has_key?(i)

        # Experiments and campaigns can generate messages. These are message generating classes.
        # We usually import message templates, images etc. for use by a specific message generating instance.
        # Imported instances are tied to the parent message generating instance by adding a tag to the experiments context that is equal to the parameterized slug for the message generating instance.
        attributes['experiment_list'] = experiment_tag if !experiment_tag.blank?
      end

      # Ignore any RecordNotUnique errors; Websites for instance are not inserted if the URL is not unique    
      begin
        import_class.create!(attributes)
      rescue ActiveRecord::RecordNotUnique
      end
    end
    
    post_import(prepared_csv_content)
  end
end