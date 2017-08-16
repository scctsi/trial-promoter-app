class DailyMetricParser
  def initialize
    @dropbox_client = DropboxClient.new
  end
  
  def name_to_date(name)
    Date.strptime(name, "%m-%d-%Y")
  end
  
  def ignore_file?(file_name)
    !file_name.index('B Free of Tobacco').nil? || !file_name.index('BFreeOfTobacco').nil?
  end
end