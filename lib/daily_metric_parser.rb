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
      parsed_file_contents = CsvFileReader.read_from_dropbox(dropbox_file_path)
    end
    
    parsed_file_contents.each.with_index do |row, index|
      next if index == 0
      parsed_metrics[row[identifier_column_index]] = row[metric_value_column_index].to_i
    end
    
    parsed_metrics
  end
end