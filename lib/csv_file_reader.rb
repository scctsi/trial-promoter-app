require 'open-uri'

class CsvFileReader
  def self.read(url)
    parsed_csv_content = []

    CSV.parse(open(url, 'r:iso-8859-1:utf-8'){|f| f.read}, col_sep: ',', headers: false) do |row|
      parsed_csv_content << row
    end

    parsed_csv_content
  end
  
  def self.read_from_dropbox(dropbox_file_path)
    dropbox_client = DropboxClient.new
    
    parsed_csv_content = []
    file, body = dropbox_client.get_file(dropbox_file_path)

    CSV.parse(body.to_s, col_sep: ',', headers: false) do |row|
      parsed_csv_content << row
    end

    parsed_csv_content
  end
end
