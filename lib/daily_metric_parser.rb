class DailyMetricParser
  def name_to_date(name)
    Date.strptime(name, "%m-%d-%Y")
  end
end