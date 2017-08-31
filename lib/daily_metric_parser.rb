class DailyMetricParser
  def name_to_date(name)
    Date.strptime(name, "%m-%d-%Y")
  end
  
  def ignore_file?(file_name)
    !file_name.index('B Free of Tobacco').nil? || !file_name.index('BFreeOfTobacco').nil?
  end
  
  def convert_to_processable_list(folders_and_files)
    processable_list = {}
    
    folders_and_files.each do |folder, files|
      files.delete_if { |file| ignore_file?(file.name) }
    end
    
    folders_and_files.each do |folder, files|
      processable_list[name_to_date(folder.name)] = files
    end

    processable_list
  end
  
  def parse_metric_from_file(dropbox_file_path, identifier_column_index, metric_value_column_index)
    parsed_metrics = {}
    
    # TODO: Unit test this next block
    if dropbox_file_path.ends_with?('.xlsx')
      parsed_file_contents = ExcelFileReader.read_from_dropbox(dropbox_file_path)
    else
      # TODO: Unit test this next block
      if dropbox_file_path.downcase.index('insights').nil?
        parsed_file_contents = CsvFileReader.read_from_dropbox(dropbox_file_path)
      else
        parsed_file_contents = CsvFileReader.read_from_dropbox(dropbox_file_path, {:skip_first_row => true})
      end
    end
    
    parsed_file_contents.each.with_index do |row, index|
      next if index == 0
      parsed_metrics[row[identifier_column_index]] = row[metric_value_column_index].to_i
    end
    
    parsed_metrics
  end
  
  def column_indices(file_name)
    return [6, 8] if file_name.end_with?('.xlsx') 
    return [0, 11] if !(file_name.index('Facebook').nil?)
    return [2, 3] if !(file_name.index('Tommy-Trogan').nil?)
    return [0, 4] if !(file_name.index('tweet_activity_metrics').nil?)
  end
  
  def parse_and_store_impressions(folders_and_files, debug = false)
    # TODO: Unit test this!
    data = {}
    filtered_folders_and_files = convert_to_processable_list(folders_and_files)
    p filtered_folders_and_files if debug
    
    filtered_folders_and_files.each do |date, files|
      files.each do |file|
        data = parse_metric_from_file(file.path_lower, *column_indices(file.name))
        p data if debug
      end
      MetricsManager.update_impressions_by_day(date, data)
    end
  end
  
  def parse_impressions(debug = false)
    # TODO: Unit test this!
    dropbox_client = DropboxClient.new
    folders_and_files = dropbox_client.recursively_list_folder('/TCORS/analytics_files/')
    if debug
      debug_folders_and_files_list = {}
      debug_folders_and_files_list[folders_and_files.keys.first] = folders_and_files.values.first
      parse_and_store_impressions(debug_folders_and_files_list, true)
    else
      parse_and_store_impressions(folders_and_files)
    end
  end
end