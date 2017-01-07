class MissingAdContentDimensionError < StandardError
  def message
    'Google Analytics data must contain the ga:adContent dimension'
  end
end