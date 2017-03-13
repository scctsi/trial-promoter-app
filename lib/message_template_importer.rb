class MessageTemplateImporter < Importer
  def post_initialize
    self.import_class = MessageTemplate
    self.column_index_attribute_mapping = { 0 => 'content', 1 => 'platforms', 2 => 'hashtags', 3 => 'tag_list', 6 => 'experiment_variables', 7 => 'original_image_filenames' }
  end

  def pre_import
    # Delete any previously associated message templates
    MessageTemplate.tagged_with(@experiment_tag, on: :experiments).each{ |message_template| message_template.destroy }
  end

  def pre_import_prepare(parsed_excel_content)
    prepared_excel_content = []

    # Step 1: Is there a header with the name 'original_image_filenames'?
    # If so, store the index of this column and remove this date out of the parsed_excel_content, storing it for later.
    original_image_filenames_index = parsed_excel_content[0].index('original_image_filenames')
    original_image_filenames = []
    if !original_image_filenames_index.nil?
      parsed_excel_content.each.with_index do |excel_row, index|
        original_image_filenames << excel_row.delete_at(original_image_filenames_index)
      end
    end

    # Step 2: Any column after the 6th column contains variables related to the experiment itself.
    # These are collapsed into a single column called experiment_variables with a hash of the values.
    if parsed_excel_content[0].length > 6
      heading_row = [parsed_excel_content[0][0..5], 'experiment_variables'].flatten
      experiment_variable_names = parsed_excel_content[0][6..parsed_excel_content[0].length]

      parsed_excel_content.each.with_index do |excel_row, index|
        if index == 0
          prepared_excel_content << heading_row
        else
          experiment_variables_hash = {}
          experiment_variable_names.each.with_index do |experiment_variable_name, column_index|
            experiment_variables_hash[experiment_variable_name] = excel_row[column_index + 6]
          end
          prepared_excel_content << [excel_row[0..5], experiment_variables_hash].flatten
        end
      end
    else
      # Just make a copy of the parsed_excel_content
      parsed_excel_content.each do |excel_row|
        prepared_excel_content << excel_row
      end
    end

    # Step 3: Add back the original_image_filenames column if it was removed for Step 2
    if !original_image_filenames_index.nil?
      prepared_excel_content.each.with_index do |prepared_excel_content_row, index|
        prepared_excel_content_row << original_image_filenames[index] if index == 0
        if original_image_filenames[index].nil?
          prepared_excel_content_row << []
        else
          prepared_excel_content_row << original_image_filenames[index].split(',').map{ |original_image_filename| original_image_filename.strip } if index != 0
        end
      end
    end

    # Step 4: Change comma-separated list of platforms to an array of symbols
    prepared_excel_content.each.with_index do |excel_row, index|
      if index != 0
        platforms = excel_row[1].to_s.split(',')
        excel_row[1] = platforms.map{ |platform| platform.strip.to_sym }
      end
    end

    # Step 5: Add {url} if missing to the content of the message templates
    prepared_excel_content.each.with_index do |excel_row, index|
      # If this is not the header row and the {url} message template variable is missing, add it.
      excel_row[0] += '{url}' if excel_row[0].index('{url}').nil? and index > 0
    end

    prepared_excel_content
  end

  def post_import(parsed_excel_content)
    # After importing the message templates, import the associated websites.
    # When importing message templates, for convenience, the CSV file also contains website_url and website_name columns (column indexes 4 and 5).
    # The data for the websites is pulled out and passed to a WebsiteImporter instance along with the tag_list in the order that WebsiteImporter expects.
    websites_parsed_csv_content = []
    parsed_excel_content.each.with_index do |excel_row, index|
      websites_parsed_csv_content << nil if index == 0 # Add a nil to represent the heading row.
      websites_parsed_csv_content << [excel_row[4], excel_row[5], excel_row[3]] if index != 0
    end
    website_importer = WebsiteImporter.new(websites_parsed_csv_content, experiment_tag)
    website_importer.import

    # For every message template belonging to the experiment, set up the image pool
    image_pool_manager = ImagePoolManager.new
    message_templates = MessageTemplate.belonging_to(@experiment_tag)
    message_templates.each do |message_template|
      image_pool_manager.add_images_by_filename(@experiment_tag, message_template.original_image_filenames, message_template)
    end
  end
end
