class SocialMediaProfilePolicy < ApplicationPolicy
  def sync_with_buffer?
    false
  end
end