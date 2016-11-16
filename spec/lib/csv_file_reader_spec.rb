require 'rails_helper'

RSpec.describe CsvFileReader do
  before do
    @csv_file_reader = CsvFileReader.new
  end
  
  it 'successfully reads a CSV file from a URL' do
    csv_url = 'http://sc-ctsi.org/trial-promoter/tweet_activity_metrics.csv'
    sample_csv_data = '"1","2"\n"3","4"'
    sample_csv_content = [['1', '2'], ['3', '4']]
    expect(@csv_file_reader).to receive(:open).and_return(StringIO.new(sample_csv_data))
    expect_any_instance_of(CSV).to receive(:read).and_return(sample_csv_content)
    csv_content = nil
    
    csv_content = @csv_file_reader.read(csv_url)

    expect(csv_content).to eq(sample_csv_content)
  end
end
