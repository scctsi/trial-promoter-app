class ClickMeterTrackingLinkNameExistsError < StandardError
  def initialize(name, domain_id)
    super("Click Meter already has a URL named #{name} on domain ID #{domain_id}")
  end
end