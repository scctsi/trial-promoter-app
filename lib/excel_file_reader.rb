require 'roo'

class ExcelFileReader
  def read(url)
    parsed_excel_content = []

    # Use the extension option if the extension is ambiguous.
    ods = Roo::Spreadsheet.open(url, extension: :xlsx)
    
    ods.each_with_pagename do |name, sheet|
      sheet.each do |row|
        parsed_excel_content << row
      end
    end

    parsed_excel_content 
  end
  
  def self.read_from_dropbox(dropbox_file_path)
    dropbox_client = DropboxClient.new

    parsed_excel_content = []
    file, body = dropbox_client.get_file(dropbox_file_path)

    # Use the extension option if the extension is ambiguous.
    io = StringIO.new(body)
    io.set_encoding Encoding::BINARY
    xlsx = Roo::Excelx.new(io)
    xlsx.each do |row|
      parsed_excel_content << row
    end

    parsed_excel_content
  end
end