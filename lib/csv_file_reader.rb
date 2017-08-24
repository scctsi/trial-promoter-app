require 'open-uri'

class CsvFileReader
  def self.read(url, options = {})
    parsed_csv_content = []

    if options[:skip_first_row]
      CSV.parse(open(url, 'r:iso-8859-1:utf-8'){|f| f.readlines.drop(1).join}, col_sep: ',', return_headers: false) do |row|
        parsed_csv_content << row
      end
    else
      CSV.parse(open(url, 'r:iso-8859-1:utf-8'){|f| f.read}, col_sep: ',', headers: false) do |row|
        parsed_csv_content << row
      end
    end

    parsed_csv_content
  end
  
  def self.read_from_dropbox(dropbox_file_path, options = {})
    # TODO: Unit test the :skip_first_row functionality for Dropbox
    dropbox_client = DropboxClient.new
    
    parsed_csv_content = []
    file, body = dropbox_client.get_file(dropbox_file_path)

    if options[:skip_first_row]
      # body = body.to_s.split(/\r?\n|\r/).drop(1).join
      p body.to_s
      
      CSV.parse(body.to_s, col_sep: ',', headers: false, :skip_lines => "Post ID") do |row|
        parsed_csv_content << row
      end
    else
      CSV.parse(body.to_s, col_sep: ',', headers: false) do |row|
        parsed_csv_content << row
      end
    end

    parsed_csv_content
  end
end
