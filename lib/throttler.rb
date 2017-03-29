class Throttler
  def self.throttle(actions_per_second)
    Kernel.sleep(1.0 / actions_per_second)
  end
end