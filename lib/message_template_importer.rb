class MessageTemplateImporter < Importer
  def post_initialize
    self.import_class = MessageTemplate
    self.column_index_attribute_mapping = { 0 => 'content', 1 => 'platform', 2 => 'hashtags', 3 => 'tag_list', 6 => 'experiment_variables' }
  end

  def pre_import
    # Delete any previously associated message templates
    MessageTemplate.tagged_with(@experiment_tag, on: :experiments).each{ |message_template| message_template.destroy }
  end
  
  def pre_import_prepare(parsed_csv_content)
    prepared_csv_content = []
    
    # Step 1: Any column after the 6th column contains variables related to the experiment itself.
    # These are collapsed into a single column called experiment_variables with a hash of the values.
    if parsed_csv_content[0].length > 6
      heading_row = [parsed_csv_content[0][0..5], 'experiment_variables'].flatten
      experiment_variable_names = parsed_csv_content[0][6..parsed_csv_content[0].length]

      parsed_csv_content.each.with_index do |csv_row, index|
        if index == 0
          prepared_csv_content << heading_row
        else
          experiment_variables_as_tags = ''
          experiment_variables_hash = {}
          experiment_variable_names.each.with_index do |experiment_variable_name, column_index|
            experiment_variables_hash[experiment_variable_name] = csv_row[column_index + 6]
          end
          experiment_variables_hash.each do |experiment_variable_name, experiment_variable_value|
            experiment_variables_as_tags += "#{experiment_variable_name}-#{experiment_variable_value},"
          end
          csv_row[3] = experiment_variables_as_tags.chomp(',') if csv_row[3].blank?
          prepared_csv_content << [csv_row[0..5], experiment_variables_hash].flatten
        end
      end
    else
      # Just make a copy of the parsed_csv_content
      parsed_csv_content.each do |csv_row|
        prepared_csv_content << csv_row
      end
    end
    
    # Step 2: If the platform column has a comma separated list of platform names, convert this row to multiple rows with a single value for platform for each row
    intermediate_prepared_csv_content = prepared_csv_content.dup
    prepared_csv_content = []
    intermediate_prepared_csv_content.each.with_index do |csv_row, index|
      if index == 0
        prepared_csv_content << csv_row
      else
        platforms = csv_row[1].to_s.split(',')
        platforms.each do |platform|
          csv_row_with_single_platform = csv_row.dup  
          csv_row_with_single_platform[1] = platform.strip
          prepared_csv_content << csv_row_with_single_platform
        end
      end
    end
    
    # Step 3: Add {url} if missing to the content of the message templates
    prepared_csv_content.each.with_index do |csv_row, index|
      # If this is not the header row and the {url} message template variable is missing, add it.
      csv_row[0] += '{url}' if csv_row[0].index('{url}').nil? and index > 0
    end
    
    prepared_csv_content
  end

  def post_import(parsed_csv_content)
    # After importing the message templates, import the associated websites.
    # When importing message templates, for convenience, the CSV file also contains website_url and website_name columns (column indexes 4 and 5).
    # The data for the websites is pulled out and passed to a WebsiteImporter instance along with the tag_list in the order that WebsiteImporter expects.
    websites_parsed_csv_content = []
    parsed_csv_content.each.with_index do |csv_row, index|
      websites_parsed_csv_content << nil if index == 0 # Add a nil to represent the heading row.
      websites_parsed_csv_content << [csv_row[4], csv_row[5], csv_row[3]] if index != 0
    end
    website_importer = WebsiteImporter.new(websites_parsed_csv_content, experiment_tag)
    website_importer.import
  end
end