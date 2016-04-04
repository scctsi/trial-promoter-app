class UtmParameterSet < ActiveRecord::Base
  attr_accessor :source, :medium, :campaign

  # def value=(value)
  #   # TODO: Unit test that nil values are set correctly
  #   if value == nil
  #     write_attribute(:value, nil)
  #     return
  #   end
  #
  #   write_attribute(:value, PostRank::URI.clean(value))
  # end
  #
  # def tracking_fragment
  #   "utm_source=#{source}&utm_medium=#{medium}&utm_campaign=#{campaign}"
  # end
end