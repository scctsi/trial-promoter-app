# require 'open-uri'

# class CsvFileReader
#   def read(url)
#     parsed_excel_content = []

#     CSV.parse(open(url, 'r:iso-8859-1:utf-8'){|f| f.read}, col_sep: ',', headers: false) do |row|
#       parsed_csv_content << row
#     end

#     parsed_csv_content
#   end
# end


require 'roo'

class ExcelFileReader
  def read(url)
    parsed_excel_content = []

    # Use the extension option if the extension is ambiguous.
    xlsx = Roo::Spreadsheet.open(url, extension: :xlsx)
    xlsx.each do |row|
      parsed_excel_content << row
    end

    parsed_excel_content
  end
end