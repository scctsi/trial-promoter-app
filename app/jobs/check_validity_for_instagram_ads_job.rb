class CheckValidityForInstagramAdsJob < ActiveJob::Base
  queue_as :default
 
  def perform
    InstagramAdImageRequirementsChecker.set_image_sizes
    InstagramAdImageRequirementsChecker.check_image_sizes
  end
end