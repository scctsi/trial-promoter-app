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
end
