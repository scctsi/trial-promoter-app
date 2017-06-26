class MetricsCalculator
  def self.click_rate(clicks, impressions)
    clicks.to_f/impressions.to_f
  end

  def self.goal_rate(conversions, sessions)
    conversions.to_f/sessions.to_f
  end
end