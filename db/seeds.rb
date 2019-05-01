# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Seed Facebook specifications
SocialMediaSpecification.where(platform: :facebook, post_type: :ad, format: :single_image, placement: :news_feed).first_or_create
# Seed Google AdWords specifications (https://support.google.com/google-ads/answer/1722124?hl=en-GB)
SocialMediaSpecification.where(platform: :google, post_type: :ad, format: :text, placement: :search_network).first_or_create
# Seed Twitter (organic) specifications
SocialMediaSpecification.where(platform: :twitter, post_type: :organic, format: :tweet, placement: :timeline).first_or_create

# Seed MetroHealth post templates
experiment = Experiment.where(name: "Ankylosing Spondylitis Survey")[0]

# Facebook post templates
if experiment.post_templates.select{ |pt| pt.social_media_specification.platform == :facebook }.count == 0
  # Facebook post templates
  post_template = PostTemplate.new
  post_template.experiment = experiment
  post_template.social_media_specification = SocialMediaSpecification.where(platform: :facebook, post_type: :ad, format: :single_image, placement: :news_feed)[0]
  post_template.content[:text] = 'New nationwide study: Why some Americans experience more severe inflammatory back pain. Join our study if you are affected! Complete the survey and get a chance to win a reward.'
  post_template.content[:headline] = 'Complete survey today!'
  post_template.content[:link_description] = 'Your time is much appreciated.'
  post_template.content[:call_to_action] = 'Learn More'
  post_template.content[:website_url] = 'http://sc-ctsi.org/metrohealth/back-pain-study.html'
  post_template.save

  post_template = PostTemplate.new
  post_template.experiment = experiment
  post_template.social_media_specification = SocialMediaSpecification.where(platform: :facebook, post_type: :ad, format: :single_image, placement: :news_feed)[0]
  post_template.content[:text] = 'Inflammatory back pain is a difficult disease to live with. Help us to better understand it and take this survey. You get a chance to win a reward.'
  post_template.content[:headline] = 'Join our study today!'
  post_template.content[:link_description] = 'Your time is much appreciated.'
  post_template.content[:call_to_action] = 'Learn More'
  post_template.content[:website_url] = 'http://sc-ctsi.org/metrohealth/back-pain-study.html'
  post_template.save
  
  post_template = PostTemplate.new
  post_template.experiment = experiment
  post_template.social_media_specification = SocialMediaSpecification.where(platform: :facebook, post_type: :ad, format: :single_image, placement: :news_feed)[0]
  post_template.content[:text] = 'Tired of constant back pain that does not improve. Join nationwide study about inflammatory back pain to find out why some are more affected than others. You get a chance to win a gift card.'
  post_template.content[:headline] = 'Take the survey today!'
  post_template.content[:link_description] = 'Your help is much appreciated.'
  post_template.content[:call_to_action] = 'Learn More'
  post_template.content[:website_url] = 'http://sc-ctsi.org/metrohealth/back-pain-study.html'
  post_template.save

  post_template = PostTemplate.new
  post_template.experiment = experiment
  post_template.social_media_specification = SocialMediaSpecification.where(platform: :facebook, post_type: :ad, format: :single_image, placement: :news_feed)[0]
  post_template.content[:text] = 'Back stiffness in the morning and difficulty moving. Sounds familiar? Nationwide study about inflammatory back pain looks at why it is worse for some people. Participate and get a chance to win a reward.'
  post_template.content[:headline] = 'Take the survey today!'
  post_template.content[:link_description] = 'Your time is much appreciated.'
  post_template.content[:call_to_action] = 'Learn More'
  post_template.content[:website_url] = 'http://sc-ctsi.org/metrohealth/back-pain-study.html'
  post_template.save

  post_template = PostTemplate.new
  post_template.experiment = experiment
  post_template.social_media_specification = SocialMediaSpecification.where(platform: :facebook, post_type: :ad, format: :single_image, placement: :news_feed)[0]
  post_template.content[:text] = 'Please participate and take the survey if you’re affected by inflammatory back pain. Nationwide study looks at why it is worse for some people. You get a chance to win a reward.'
  post_template.content[:headline] = 'Complete the survey today!'
  post_template.content[:link_description] = 'Your time is much appreciated.'
  post_template.content[:call_to_action] = 'Learn More'
  post_template.content[:website_url] = 'http://sc-ctsi.org/metrohealth/back-pain-study.html'
  post_template.save

  post_template = PostTemplate.new
  post_template.experiment = experiment
  post_template.social_media_specification = SocialMediaSpecification.where(platform: :facebook, post_type: :ad, format: :single_image, placement: :news_feed)[0]
  post_template.content[:text] = 'Why do some people have worse back pain or morning stiffness than others? Help us to find out if you are affected by inflammatory back pain and join nationwide research study. You get a chance to win a gift card.'
  post_template.content[:headline] = 'Complete the survey today!'
  post_template.content[:link_description] = 'Your help is much appreciated.'
  post_template.content[:call_to_action] = 'Learn More'
  post_template.content[:website_url] = 'http://sc-ctsi.org/metrohealth/back-pain-study.html'
  post_template.save

  post_template = PostTemplate.new
  post_template.experiment = experiment
  post_template.social_media_specification = SocialMediaSpecification.where(platform: :facebook, post_type: :ad, format: :single_image, placement: :news_feed)[0]
  post_template.content[:text] = 'Why are Black patients more affected by inflammatory back pain than White folks? Nationwide study tries to find an answer. Help us find out and take our survey. You get a chance to win a gift card.'
  post_template.content[:headline] = 'Complete the survey today!'
  post_template.content[:link_description] = 'Your help is much appreciated.'
  post_template.content[:call_to_action] = 'Learn More'
  post_template.content[:website_url] = 'http://sc-ctsi.org/metrohealth/back-pain-study.html'
  post_template.save
end

if experiment.post_templates.select{ |pt| pt.social_media_specification.platform == :google }.count == 0
  # Google post templates
  post_template = PostTemplate.new
  post_template.experiment = experiment
  post_template.social_media_specification = SocialMediaSpecification.where(platform: :google, post_type: :ad, format: :text, placement: :search_network)[0]
  post_template.content[:headline_1] = 'Nationwide Study on Back Pain'
  post_template.content[:description_1] = 'Why some Americans experience more severe inflammatory back pain?'
  post_template.content[:description_2] = 'Join our study if you are affected! Complete the survey and get a chance to win a reward.'
  post_template.content[:website_url] = 'http://sc-ctsi.org/metrohealth/back-pain-study.html'
  post_template.save

  post_template = PostTemplate.new
  post_template.experiment = experiment
  post_template.social_media_specification = SocialMediaSpecification.where(platform: :google, post_type: :ad, format: :text, placement: :search_network)[0]
  post_template.content[:headline_1] = 'Join Our Study on Back Pain!'
  post_template.content[:description_1] = 'Inflammatory back pain is a difficult disease to live with.'
  post_template.content[:description_2] = 'Help us to better understand it and take this survey. You get a chance to win a reward.'
  post_template.content[:website_url] = 'http://sc-ctsi.org/metrohealth/back-pain-study.html'
  post_template.save

  post_template = PostTemplate.new
  post_template.experiment = experiment
  post_template.social_media_specification = SocialMediaSpecification.where(platform: :google, post_type: :ad, format: :text, placement: :search_network)[0]
  post_template.content[:headline_1] = 'Suffering from Back Pain?'
  post_template.content[:description_1] = 'Tired of constant back pain that does not improve? Here’s a chance to win a gift card.'
  post_template.content[:description_2] = 'Join nationwide study about inflammatory back pain to find out why.'
  post_template.content[:website_url] = 'http://sc-ctsi.org/metrohealth/back-pain-study.html'
  post_template.save

  post_template = PostTemplate.new
  post_template.experiment = experiment
  post_template.social_media_specification = SocialMediaSpecification.where(platform: :google, post_type: :ad, format: :text, placement: :search_network)[0]
  post_template.content[:headline_1] = 'Constant Back Pain is Serious'
  post_template.content[:description_1] = 'Back stiffness in the morning and difficulty moving. Sounds familiar? Chance for reward.'
  post_template.content[:description_2] = 'Nationwide study about inflammatory back pain looks at why it is worse for some people.'
  post_template.content[:website_url] = 'http://sc-ctsi.org/metrohealth/back-pain-study.html'
  post_template.save

  post_template = PostTemplate.new
  post_template.experiment = experiment
  post_template.social_media_specification = SocialMediaSpecification.where(platform: :google, post_type: :ad, format: :text, placement: :search_network)[0]
  post_template.content[:headline_1] = 'Join Back Pain Study'
  post_template.content[:description_1] = 'Please participate and take the survey if you’re affected by inflammatory back pain.'
  post_template.content[:description_2] = 'Nationwide study looks at why it is worse for some people. Chance to win a reward.'
  post_template.content[:website_url] = 'http://sc-ctsi.org/metrohealth/back-pain-study.html'
  post_template.save

  post_template = PostTemplate.new
  post_template.experiment = experiment
  post_template.social_media_specification = SocialMediaSpecification.where(platform: :google, post_type: :ad, format: :text, placement: :search_network)[0]
  post_template.content[:headline_1] = 'Back Pain? Take Our Survey!'
  post_template.content[:description_1] = 'Why do some people have worse back pain or morning stiffness than others?'
  post_template.content[:description_2] = 'Help us to find out if you are affected by inflammatory back pain for chance at gift card.'
  post_template.content[:website_url] = 'http://sc-ctsi.org/metrohealth/back-pain-study.html'
  post_template.save

  post_template = PostTemplate.new
  post_template.experiment = experiment
  post_template.social_media_specification = SocialMediaSpecification.where(platform: :google, post_type: :ad, format: :text, placement: :search_network)[0]
  post_template.content[:headline_1] = 'Nationwide Study on Back Pain'
  post_template.content[:description_1] = 'Why some Americans experience more severe inflammatory back pain?'
  post_template.content[:description_2] = 'Join our study if you are affected! Complete the survey and get a chance to win a reward.'
  post_template.content[:website_url] = 'http://sc-ctsi.org/metrohealth/back-pain-study.html'
  post_template.save

  post_template = PostTemplate.new
  post_template.experiment = experiment
  post_template.social_media_specification = SocialMediaSpecification.where(platform: :google, post_type: :ad, format: :text, placement: :search_network)[0]
  post_template.content[:headline_1] = 'Inflammatory Back Pain Study'
  post_template.content[:description_1] = 'Constant stiffness? Help us to find out if you are affected by inflammatory back pain.'
  post_template.content[:description_2] = 'Join nationwide study for chance of reward'
  post_template.content[:website_url] = 'http://sc-ctsi.org/metrohealth/back-pain-study.html'
  post_template.save

  post_template = PostTemplate.new
  post_template.experiment = experiment
  post_template.social_media_specification = SocialMediaSpecification.where(platform: :google, post_type: :ad, format: :text, placement: :search_network)[0]
  post_template.content[:headline_1] = 'Ankylosing Spondylitis Study'
  post_template.content[:description_1] = 'Constant back pain? You may have ankylosing spondylitis, a rare inflammatory condition.'
  post_template.content[:description_2] = "Join nationwide study. You'll be entered into a raffle for a reward."
  post_template.content[:website_url] = 'http://sc-ctsi.org/metrohealth/back-pain-study.html'
  post_template.save
end

# Twitter post templates
if experiment.post_templates.select{ |pt| pt.social_media_specification.platform == :twitter }.count == 0
  post_template = PostTemplate.new
  post_template.experiment = experiment
  post_template.social_media_specification = SocialMediaSpecification.where(platform: :twitter, post_type: :organic, format: :tweet, placement: :timeline)[0]
  post_template.content[:text] = 'New nationwide study: Why some Americans experience more severe inflammatory back pain. Join our study if you are affected! Complete the survey and get a chance to win a reward.'
  post_template.content[:hashtags] = '#backpain #ankylosingspondylitis #MonsterPainInTheAS #sacroiliitis'
  post_template.content[:website_url] = 'http://sc-ctsi.org/metrohealth/back-pain-study.html'
  post_template.save

  post_template = PostTemplate.new
  post_template.experiment = experiment
  post_template.social_media_specification = SocialMediaSpecification.where(platform: :twitter, post_type: :organic, format: :tweet, placement: :timeline)[0]
  post_template.content[:text] = 'Inflammatory back pain is a difficult disease to live with. Help us to better understand it and take this survey. You get a chance to win a reward.'
  post_template.content[:hashtags] = '#backpain #ankylosingspondylitis #MonsterPainInTheAS #sacroiliitis'
  post_template.content[:website_url] = 'http://sc-ctsi.org/metrohealth/back-pain-study.html'
  post_template.save

  post_template = PostTemplate.new
  post_template.experiment = experiment
  post_template.social_media_specification = SocialMediaSpecification.where(platform: :twitter, post_type: :organic, format: :tweet, placement: :timeline)[0]
  post_template.content[:text] = 'Tired of constant back pain that does not improve. Join nationwide study about inflammatory back pain to find out why some are more affected than others. You get a chance to win a gift card.'
  post_template.content[:hashtags] = '#backpain #ankylosingspondylitis #MonsterPainInTheAS #sacroiliitis'
  post_template.content[:website_url] = 'http://sc-ctsi.org/metrohealth/back-pain-study.html'
  post_template.save

  post_template = PostTemplate.new
  post_template.experiment = experiment
  post_template.social_media_specification = SocialMediaSpecification.where(platform: :twitter, post_type: :organic, format: :tweet, placement: :timeline)[0]
  post_template.content[:text] = 'Back stiffness in the morning and difficulty moving. Sounds familiar? Nationwide study about inflammatory back pain looks at why it is worse for some people. Participate and get a chance to win a reward.'
  post_template.content[:hashtags] = '#backpain #ankylosingspondylitis #MonsterPainInTheAS #sacroiliitis'
  post_template.content[:website_url] = 'http://sc-ctsi.org/metrohealth/back-pain-study.html'
  post_template.save

  post_template = PostTemplate.new
  post_template.experiment = experiment
  post_template.social_media_specification = SocialMediaSpecification.where(platform: :twitter, post_type: :organic, format: :tweet, placement: :timeline)[0]
  post_template.content[:text] = 'Please participate and take the survey if you’re affected by inflammatory back pain. Nationwide study looks at why it is worse for some people. You get a chance to win a reward.'
  post_template.content[:hashtags] = '#backpain #ankylosingspondylitis #MonsterPainInTheAS #sacroiliitis'
  post_template.content[:website_url] = 'http://sc-ctsi.org/metrohealth/back-pain-study.html'
  post_template.save

  post_template = PostTemplate.new
  post_template.experiment = experiment
  post_template.social_media_specification = SocialMediaSpecification.where(platform: :twitter, post_type: :organic, format: :tweet, placement: :timeline)[0]
  post_template.content[:text] = 'Why do some people have worse back pain or morning stiffness than others? Help us to find out if you are affected by inflammatory back pain and join nationwide research study. You get a chance to win a gift card.'
  post_template.content[:hashtags] = '#backpain #ankylosingspondylitis #MonsterPainInTheAS #sacroiliitis'
  post_template.content[:website_url] = 'http://sc-ctsi.org/metrohealth/back-pain-study.html'
  post_template.save

  post_template = PostTemplate.new
  post_template.experiment = experiment
  post_template.social_media_specification = SocialMediaSpecification.where(platform: :twitter, post_type: :organic, format: :tweet, placement: :timeline)[0]
  post_template.content[:text] = 'Why are Black patients more affected by inflammatory back pain than White folks? Nationwide study tries to find an answer. Help us find out and take our survey. You get a chance to win a gift card.'
  post_template.content[:hashtags] = '#backpain #ankylosingspondylitis #MonsterPainInTheAS #sacroiliitis'
  post_template.content[:website_url] = 'http://sc-ctsi.org/metrohealth/back-pain-study.html'
  post_template.save
end

# if PostTemplate.count == 0
#   experiment = Experiment.where(name: "Filipino Family Health Initiative")[0]
  
  
#   post_template = PostTemplate.new
#   post_template.experiment = experiment
#   post_template.social_media_specification = SocialMediaSpecification.first
#   post_template.content[:text] = 'How important is the academic and social success of your child to you?  Come join a community study led by Dr. Joyce Javier that may help improve the well-being of Filipino youth.'
#   post_template.content[:headline] = 'Get in touch today!'
#   post_template.content[:link_description] = 'Monetary incentives available'
#   post_template.content[:call_to_action] = 'Learn More'
#   post_template.content[:website_url] = 'http://www.filipinofamilyhealth.com/'
#   post_template.save
  
#   post_template = PostTemplate.new
#   post_template.experiment = experiment
#   post_template.social_media_specification = SocialMediaSpecification.first
#   post_template.content[:text] = 'Suicide is the leading cause of death among Asian and Pacific Islander teens in the U.S.? Come join a community study led by Dr. Joyce Javier to learn how to raise mentally strong kids.'
#   post_template.content[:headline] = 'Sign up today! It’s free.'
#   post_template.content[:link_description] = 'Monetary incentives available'
#   post_template.content[:call_to_action] = 'Contact Us'
#   post_template.content[:website_url] = 'http://www.filipinofamilyhealth.com/'
#   post_template.save
  
#   post_template = PostTemplate.new
#   post_template.experiment = experiment
#   post_template.social_media_specification = SocialMediaSpecification.first
#   post_template.content[:text] = 'The majority of college students are not prepared to deal with disappointment, anxiety, and loneliness. Learn how to best prepare your child through this community study. For parents with kids 8-12 years.'
#   post_template.content[:headline] = 'Sign up today! It’s free.'
#   post_template.content[:link_description] = 'Monetary incentives available '
#   post_template.content[:call_to_action] = 'Contact Us'
#   post_template.content[:website_url] = 'http://www.filipinofamilyhealth.com/'
#   post_template.save
# end