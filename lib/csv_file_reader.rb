require 'open-uri'

class CsvFileReader
  def read(url)
    CSV.new(open(url)).read
  end
end