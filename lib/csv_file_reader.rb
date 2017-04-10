require 'open-uri'

class CsvFileReader
  def self.read(url)
    parsed_csv_content = []

    CSV.parse(open(url, 'r:iso-8859-1:utf-8'){|f| f.read}, col_sep: ',', headers: false) do |row|
      parsed_csv_content << row
    end

    parsed_csv_content
  end
end
