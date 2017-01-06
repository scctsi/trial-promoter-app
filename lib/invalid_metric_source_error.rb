class InvalidMetricSourceError < StandardError
  def initialize(source, allowed_platform)
    super("Message platform is #{allowed_platform}, but metric source was #{source}")
  end
end