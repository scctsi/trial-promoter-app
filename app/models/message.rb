class Message < ActiveRecord::Base
  serialize :content
  serialize :statistics
  serialize :service_statistics

  validates :content, presence: true
  validates :campaign, presence: true
  validates :medium, presence: true

  belongs_to :message_template
  belongs_to :clinical_trial

  def self.generate(start_date = DateTime.now)
    return # Trial Promoter was launched on 09/17/2015. Never run this method again.

  #   # TODO: Unit test
  #   Message.destroy_all
  #
  #   Bitly.use_api_version_3
  #   Bitly.configure do |config|
  #     config.api_version = 3
  #     config.access_token = '21c4a40d1746ea7d0815aa33a9a3137c50c389e8'
  #   end
  #
  #   scheduled_at = start_date
  #
  #   clinical_trials_sets = randomize_clinical_trials
  #   clinical_trials_set_1 = clinical_trials_sets[0]
  #   clinical_trials_set_2 = clinical_trials_sets[1]
  #
  #   twitter_awareness_message_templates = MessageTemplate.where(:message_type => 'awareness', :platform => 'twitter').to_a
  #   twitter_recruiting_message_templates = MessageTemplate.where(:message_type => 'recruiting', :platform => 'twitter').to_a
  #   twitter_uscprofiles_message_templates = MessageTemplate.where(:platform => 'twitter_uscprofiles').to_a
  #   facebook_awareness_message_templates = MessageTemplate.where(:message_type => 'awareness', :platform => 'facebook').to_a
  #   facebook_recruiting_message_templates = MessageTemplate.where(:message_type => 'recruiting', :platform => 'facebook').to_a
  #   facebook_uscprofiles_message_templates = MessageTemplate.where(:platform => 'facebook_uscprofiles').to_a
  #   google_awareness_message_templates = MessageTemplate.where(:message_type => 'awareness', :platform => 'google').to_a
  #   google_recruiting_message_templates = MessageTemplate.where(:message_type => 'recruiting', :platform => 'google').to_a
  #   google_uscprofiles_message_templates = MessageTemplate.where(:platform => 'google_uscprofiles').to_a
  #   youtube_search_results_awareness_message_templates = MessageTemplate.where(:message_type => 'awareness', :platform => 'youtube_search_results').to_a
  #   youtube_search_results_recruiting_message_templates = MessageTemplate.where(:message_type => 'recruiting', :platform => 'youtube_search_results').to_a
  #   youtube_uscprofiles_message_templates = MessageTemplate.where(:platform => 'youtube_uscprofiles').to_a
  #   diseases = clinical_trials_set_1.collect { |clinical_trial| clinical_trial.disease }
  #   disease_hashtags = clinical_trials_set_1.collect { |clinical_trial| clinical_trial.hashtags }
  #
  #   random = Random.new
  #
  #   if !Rails.env.production?
  #     WebMock.allow_net_connect!
  #   end
  #
  #   use_image_for_profile_message = false
  #
  #   (0..(clinical_trials_set_1.length - 1)).each do |i|
  #     # Organic message + image + awareness message template
  #     # Organic message + image + recruitment message template
  #
  #     # ----------------
  #     # TWITTER PLATFORM
  #     # ----------------
  #     # Organic
  #     # Awareness
  #     begin # From set 1 with no image
  #     end until create_message(clinical_trials_set_1[i], twitter_awareness_message_templates.sample(1, random: random)[0], scheduled_at, 'organic')
  #     # PROFILES Promotion
  #     begin # Alternate with no image and image
  #     end until create_message(nil, twitter_uscprofiles_message_templates.sample(1, random: random)[0], scheduled_at, 'organic', use_image_for_profile_message)
  #     # 32 is length of <%= message[:disease_hashtag] %>, 20 is length of <%= message[:ur;] %>, 22 is length of twitter URL, 24 is length of image URL, 11 is length of @KeckMedUSC
  #     begin # From set 2 with image;
  #     end until create_message(clinical_trials_set_2[i], twitter_awareness_message_templates.select{ |template| (template.content.length - 32 - 20 + 22 - 11 + clinical_trials_set_2[i].hashtags[0].length + 24 <= 140) }.sample(1, random: random)[0], scheduled_at, 'organic', true)
  #     # Recruiting
  #     begin # From set 1 with no image
  #     end until create_message(clinical_trials_set_1[i], twitter_recruiting_message_templates.sample(1, random: random)[0], scheduled_at + 1, 'organic')
  #     begin # From set 2 with image
  #     end until create_message(clinical_trials_set_2[i], twitter_recruiting_message_templates.select{ |template| (template.content.length - 32 - 20 + 22 - 11 + clinical_trials_set_2[i].hashtags[0].length + 24 <= 140) }.sample(1, random: random)[0], scheduled_at + 1, 'organic', true)
  #
  #     # Twitter does not allow ads for clinical trials
  #
  #     # -----------------
  #     # FACEBOOK PLATFORM
  #     # -----------------
  #     # Organic
  #     # Awareness
  #     # From set 1 with no image
  #     begin
  #     end until create_message(clinical_trials_set_1[i], facebook_awareness_message_templates.sample(1, random: random)[0], scheduled_at, 'organic')
  #     # PROFILES Promotion (alternate image and no image)
  #     begin
  #     end until create_message(nil, facebook_uscprofiles_message_templates.sample(1, random: random)[0], scheduled_at, 'organic', use_image_for_profile_message)
  #     # From set 2 with image
  #     begin
  #     end until create_message(clinical_trials_set_2[i], facebook_awareness_message_templates.sample(1, random: random)[0], scheduled_at, 'organic', true)
  #     # Recruiting
  #     # From set 1 with no image
  #     begin
  #     end until create_message(clinical_trials_set_1[i], facebook_recruiting_message_templates.sample(1, random: random)[0], scheduled_at + 1, 'organic')
  #     # From set 2 with image
  #     begin
  #     end until create_message(clinical_trials_set_2[i], facebook_recruiting_message_templates.sample(1, random: random)[0], scheduled_at + 1, 'organic', true)
  #
  #     # Paid
  #     # Awareness
  #     # From set 1 with no image
  #     begin
  #     end until create_message(clinical_trials_set_1[i], facebook_awareness_message_templates.sample(1, random: random)[0], scheduled_at, 'paid')
  #     # PROFILES Promotion (alternate image and no image)
  #     begin
  #     end until create_message(nil, facebook_uscprofiles_message_templates.sample(1, random: random)[0], scheduled_at, 'paid', use_image_for_profile_message)
  #     # From set 2 with image
  #     begin
  #     end until create_message(clinical_trials_set_2[i], facebook_awareness_message_templates.sample(1, random: random)[0], scheduled_at, 'paid', true)
  #     # Recruiting
  #     # From set 1 with no image
  #     begin
  #     end until create_message(clinical_trials_set_1[i], facebook_recruiting_message_templates.sample(1, random: random)[0], scheduled_at + 1, 'paid')
  #     # From set 2 with image
  #     begin
  #     end until create_message(clinical_trials_set_2[i], facebook_recruiting_message_templates.sample(1, random: random)[0], scheduled_at + 1, 'paid', true)
  #
  #     # --------
  #     # Google
  #     # --------
  #     # Paid
  #     # Awareness
  #     # From set 1 with no image
  #     begin
  #     end until create_message(clinical_trials_set_1[i], google_awareness_message_templates.sample(1, random: random)[0], scheduled_at, 'paid')
  #     # Recruiting
  #     # From set 1 with no image
  #     begin
  #     end until create_message(clinical_trials_set_1[i], google_recruiting_message_templates.sample(1, random: random)[0], scheduled_at + 1, 'paid')
  #     # Profiles Promotion with no image
  #     begin
  #     end until create_message(nil, google_uscprofiles_message_templates.sample(1, random: random)[0], scheduled_at, 'paid')
  #
  #     # --------
  #     # YouTube
  #     # --------
  #     # Paid
  #     # Awareness
  #     # From set 1 with no image
  #     begin
  #     end until create_message(clinical_trials_set_1[i], youtube_search_results_awareness_message_templates.sample(1, random: random)[0], scheduled_at, 'paid')
  #     # From set 2 with image
  #     begin
  #     end until create_message(clinical_trials_set_2[i], youtube_search_results_awareness_message_templates.sample(1, random: random)[0], scheduled_at, 'paid', true)
  #     # Recruiting
  #     # From set 1 with no image
  #     begin
  #     end until create_message(clinical_trials_set_1[i], youtube_search_results_recruiting_message_templates.sample(1, random: random)[0], scheduled_at + 1, 'paid')
  #     # From set 2 with no image
  #     begin
  #     end until create_message(clinical_trials_set_2[i], youtube_search_results_recruiting_message_templates.sample(1, random: random)[0], scheduled_at + 1, 'paid', true)
  #     # Profiles Promotion
  #     begin
  #     end until create_message(nil, youtube_uscprofiles_message_templates.sample(1, random: random)[0], scheduled_at, 'paid')
  #
  #     scheduled_at = scheduled_at + 2
  #     # Alternate use of image for profile images
  #     use_image_for_profile_message = !use_image_for_profile_message
  #
  #     # Sleep outside it not in development environment so that the system does not hit Bitly's API limits
  #     if Rails.env.development?
  #     else
  #       sleep 120
  #     end
  #   end
  #
  #   if !Rails.env.production?
  #     WebMock.disable_net_connect!
  #   end
  end

  def self.create_message(clinical_trial, message_template, scheduled_at, medium, image_required = false)
    message = Message.new
    message.clinical_trial = clinical_trial
    message.message_template = message_template
    message.scheduled_at = scheduled_at
    message.medium = medium
    message.campaign = self.campaign_value
    tracking_url = TrackingUrl.new(message).value(medium, self.campaign_value)
    message.tracking_url = tracking_url
    message.image_required = image_required

    replace_parameters(message)
    # assign_random_image(message) if message.image_required

    if is_valid?(message)
      message.save
      return true
    else
      return false
    end
  end

  def self.replace_parameters(message)
    if !(message.clinical_trial.blank?)
      disease = message.clinical_trial.disease
      pi_name = message.clinical_trial.pi_name
    else
      disease = '<%= message[:disease] %>'
      pi_name = ''
    end
    url_shortener = UrlShortener.new

    message_template_content = message.message_template.content
    if message.message_template.platform.start_with?('google') || message.message_template.platform.start_with?('youtube')
      message.content = []
      message.content[0] = message.message_template.content[0].gsub('<%= message[:disease] %>', disease)
      message.content[1] = 'URL' # We are not shortening the Google or Youtube URLs url_shortener.shorten(message.tracking_url)
      message.content[2] = message.message_template.content[1].gsub('<%= message[:disease] %>', disease)
      message.content[3] = message.message_template.content[2].gsub('<%= message[:disease] %>', disease)
      if message.message_template.platform.start_with?('youtube')
        message.content[4] = message.message_template.content[3].gsub('<%= message[:disease] %>', disease)
      end
    else
      if Rails.env.development?
        message.content = message_template_content.gsub('<%= message[:url] %>', 'http://bit.ly/12345678')
      else
        message.content = message_template_content.gsub('<%= message[:url] %>', url_shortener.shorten(message.tracking_url))
        if message.content.index('http://bit.ly/123456') != nil
          message.content = message.content.gsub('http://bit.ly/123456', url_shortener.shorten(message.tracking_url))
        end
      end
      message.content = message.content.gsub('<%= message[:pi] %>', pi_name)
      message.content = message.content.gsub('@KeckMedUSC', '') if message.image_required # We need the extra 11 characters of space for Twitter messages with images (Twitter images take up 24 extra characters)
      tag(message) if !(message.clinical_trial.blank?)
    end
  end

  def self.tag(message)
    message.content = message.content.gsub('<%= message[:disease_hashtag] %>', message.clinical_trial.hashtags[0])
    if !message.clinical_trial.hashtags[1].blank?
      # Always add a secondary hashtag for Facebook messages
      if message.message_template.platform == 'facebook'
        message.content += " #{message.clinical_trial.hashtags[1]}" # message.clinical_trial.hashtags[1] is the second available hashtag
      end

      # Add a secondary hashtag for Twitter if possible (only for Twitter posts without an image)
      if message.message_template.platform == 'twitter' and !message.image_required
        current_message_content = message.content
        message.content += " #{message.clinical_trial.hashtags[1]}" # message.clinical_trial.hashtags[1] is the second available hashtag
        message.content = current_message_content if message.content.length > 140
      end
    end
  end

  def self.assign_random_image(message)
    # No random images are assigned by Trial Promoter
    # image_names = %w(children_1.png cutout_man.png cutout_woman.png diabetes_magnifier.png faces.png faces_2.png healthy_man.png healthy_woman.png
    #   healthy_woman_2.png heart.png hero_1.png hero_2.png hero_3.png hero_4.png hero_5.png mother_child.png
    #   patient.png physician_1.png physician_2.png research.png rope.png stethoscope.png together.png together_2.png together_2b.png)
    #
    # random = Random.new
    #
    # image = image_names.sample(1, random: random)[0]
    #
    # message.thumbnail_url = "http://sc-ctsi.org/trial_promoter/image_pool/#{image}".chomp('.png') + '_thumbnail.png'
    # message.image_url = "http://sc-ctsi.org/trial_promoter/image_pool/#{image}"
    # message.save(:validate => false)
  end

  def self.campaign_value
    return_value = 'trial-promoter-development'

    if !ENV['CAMPAIGN'].blank?
      return_value  = ENV['CAMPAIGN']
    end

    return(return_value)
  end

  def self.is_valid?(message)
    # Reject the smoker/smoking message templates as none of our lung cancer trials mention smoking.
    return false if (message.content.index('smoker') != nil) || (message.content.index('smoking') != nil)

    if message.message_template.platform.start_with?('twitter') and message.content.length > 140
      return false
    end

    if message.message_template.platform.start_with?('twitter') and message.image_required and message.content.length > 140 - 24
      return false
    end

    if message.message_template.platform.start_with?('google') || message.message_template.platform.start_with?('youtube')
      return false if message.content[0].length > 25 || message.content[2].length > 35 || message.content[3].length > 35
    end

    return true
  end

  def self.randomize_clinical_trials
    clinical_trials_set_1 = ClinicalTrial.where(:randomization_status => 'Selected').to_a.shuffle

    # Reshuffle while there is atleast one clinical trial that is in the same position as another clinical trial in both sets
    reshuffle = false
    clinical_trials_set_2 = clinical_trials_set_1.shuffle
    loop do
      [0..(clinical_trials_set_1.length - 1)].each_with_index do |clinical_trial, index|
        reshuffle = true if clinical_trials_set_1[index] == clinical_trials_set_2[index]
      end

      break if reshuffle == false

      reshuffle = false
      clinical_trials_set_2 = clinical_trials_set_1.shuffle
    end

    return [clinical_trials_set_1, clinical_trials_set_2]
  end

  def permanent_image_url
    # Dropbox thumbnail URLs are of this form: https://api-content.dropbox.com/r11/t/AAANnP_XPBxb28PEfpYSoSap92axlFNxaN4CT4G1i5SKNA/12/307720262/png/_/0/4/children_1.png/CMbg3ZIBIAEgAiADIAQgBSAGIAcoAigH/ps2uob5dswyejiz/AADF_c9_6efgbktZAVxuxLDia/children_1.png?bounding_box=75&mode=fit
    # We pull images from a web location located at sc-ctsi.org/trial_promoter/image_pool
    return "http://sc-ctsi.org/trial_promoter/image_pool/#{thumbnail_url[(thumbnail_url.rindex('/') + 1)..(thumbnail_url.rindex('?') - 1)]}" if !(thumbnail_url.start_with?('http://sc-ctsi.org'))
    image_url
  end

  def self.fix
    # One time fixes to messages. Once the fixes are in place, make sure to comment out the FIX that was applied, but most fixes should be able to run multiple times
    # without any side effect

    # Bitly.use_api_version_3
    # Bitly.configure do |config|
    #   config.api_version = 3
    #   config.access_token = '21c4a40d1746ea7d0815aa33a9a3137c50c389e8'
    # end
    #
    # # Fix 1: Replace http://bit.ly/123456 with the shortened URL
    # url_shortener = UrlShortener.new
    # Message.all.each do |message|
    #   if message.content.index('http://bit.ly/123456') != nil
    #     message.content = message.content.gsub('http://bit.ly/123456', url_shortener.shorten(message.tracking_url))
    #     message.save
    #   end
    # end

    # Fix 2: Replace disease parameters for Profile messages
    # clinical_trials = ClinicalTrial.all
    # diseases = clinical_trials.collect { |clinical_trial| clinical_trial.disease }
    # disease_hashtags = clinical_trials.collect { |clinical_trial| clinical_trial.hashtags }
    # random = Random.new
    # Message.all.each do |message|
    #   random_disease_hashtags = disease_hashtags.sample(1, random: random)[0]
    #   random_disease = diseases.sample(1, random: random)[0]
    #
    #   # Twitter and Facebook profile message templates
    #   if message.message_template.platform == 'twitter_uscprofiles' or message.message_template.platform == 'facebook_uscprofiles'
    #     if message.content.index('#disease') != nil
    #       message.content = message.content.gsub('#disease', random_disease_hashtags[0])
    #       message.save
    #     end
    #     if message.content.index('<%= message[:disease_hashtag] %>') != nil
    #       message.content = message.content.gsub('<%= message[:disease_hashtag] %>', random_disease_hashtags[0])
    #       message.save
    #     end
    #     if message.content.index('#secondary disease hashtag') != nil and random_disease_hashtags.count > 1
    #       message.content = message.content.gsub('#secondary disease hashtag', random_disease_hashtags[1])
    #       message.save
    #     end
    #   end
    #
    #   # Google and YouTube profile message templates
    #   if message.message_template.platform == 'google_uscprofiles' or message.message_template.platform == 'youtube_uscprofiles'
    #     (0..3).each do |index|
    #       if message.content[index].index('Search by <%= message[:disease] %>, name, etc.') != nil # Google and YouTube profile templates had an incorrect parameter
    #         message.content[index] = message.content[index].gsub('Search by <%= message[:disease] %>, name, etc.', 'Search by disease, name, etc.')
    #         message.save
    #       end
    #
    #       max_length = 35
    #       max_length = 25 if index == 0 # Length limit is 25 characters for headline
    #
    #       if message.content[index].index('<%= message[:disease] %>') != nil
    #         if message.content[index].gsub('<%= message[:disease] %>', random_disease).length > max_length
    #           message.content[index].gsub('<%= message[:disease] %>', 'Clinical')
    #           message.save
    #         else
    #           message.content[index] = message.content[index].gsub('<%= message[:disease] %>', random_disease)
    #           message.save
    #         end
    #       end
    #
    #       if message.content[index].index('<%= message[:disease] %>') != nil
    #         if message.content[index].gsub('<%= message[:disease] %>', random_disease).length > max_length
    #           message.content[index].gsub('<%= message[:disease] %>', 'clinical')
    #           message.save
    #         else
    #           message.content[index] = message.content[index].gsub('<%= message[:disease] %>', random_disease)
    #           message.save
    #         end
    #       end
    #
    #     end
    #   end
    #
    #   if message.message_template.platform == 'youtube_uscprofiles'
    #     message.content[4] = message.content[4].gsub('<%= message[:disease] %>', 'disease')
    #     message.save
    #   end
    # end

    # Fix 3: Fix recruiting, Image Youtube video messages
    # First, identify the image and recruiting message. Then find the corresponding image and recruiting image ad
    # youtube_search_results_recruiting_message_templates = MessageTemplate.where(:message_type => 'recruiting', :platform => 'youtube_search_results').to_a
    # random = Random.new
    # fix_count = 0
    #
    # Message.all.each do |message|
    #   if message.message_template.platform == 'youtube_search_results' and message.message_template.message_type == 'recruiting' and message.image_required
    #     message_id = message.id.to_i
    #     message_to_use_for_fix_message_id = message_id - 2
    #     message_to_use_for_fix = Message.find(message_to_use_for_fix_message_id)
    #
    #     begin
    #       message.clinical_trial = message_to_use_for_fix.clinical_trial
    #       message.message_template = youtube_search_results_recruiting_message_templates.sample(1, random: random)[0]
    #       tracking_url = TrackingUrl.new(message).value('paid', self.campaign_value)
    #       message.tracking_url = tracking_url
    #
    #       replace_parameters(message)
    #       # assign_random_image(message) if message.image_required
    #
    #       if is_valid?(message)
    #         fix_count = fix_count + 1
    #         message.save
    #       end
    #     end until is_valid?(message)
    #   end
    # end
    #
    # p "Fixed: " + fix_count.to_s
  end
end