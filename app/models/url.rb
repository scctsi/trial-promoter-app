class Url < ActiveRecord::Base
  has_one :utm_parameter_set

  validates :value, presence: true

  def value=(value)
    # TODO: Unit test that nil values are set correctly
    if value == nil
      write_attribute(:value, nil)
      return
    end

    write_attribute(:value, PostRank::URI.clean(value))
  end
end