class SocialMediaProfilesController < ApplicationController
  before_action :set_social_media_profile, only: [:edit, :update]

  def index
    authorize SocialMediaProfile
    @social_media_profiles = policy_scope(SocialMediaProfile)
  end

  def edit
  end

  def update
    @social_media_profile.update(social_media_profile_params)
    redirect_to social_media_profiles_url
  end

  def sync_with_buffer
    experiment = Experiment.find(params[:experiment])
    authorize SocialMediaProfile
    BufferClient.get_social_media_profiles(experiment)
    redirect_to social_media_profiles_url
  end

  private

  def set_social_media_profile
    @social_media_profile = SocialMediaProfile.find(params[:id])
    authorize @social_media_profile
  end

  def social_media_profile_params
    # TODO: Unit test this
    params.require(:social_media_profile).permit(:allowed_mediums => [])
  end
end
