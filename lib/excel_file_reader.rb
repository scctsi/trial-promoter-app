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