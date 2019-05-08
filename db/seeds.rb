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

# Seed MAMITA post templates
experiment = Experiment.where(name: "MAMITA")[0]

# Facebook post templates
if experiment.post_templates.select{ |pt| pt.social_media_specification.platform == :facebook }.count == 0
  # Facebook post templates
  post_template = PostTemplate.new
  post_template.experiment = experiment
  post_template.social_media_specification = SocialMediaSpecification.where(platform: :facebook, post_type: :ad, format: :single_image, placement: :news_feed)[0]
  post_template.content[:text] = 'How sugar affects Latina moms and their babies. Come join our free MAMITA study if you are a pregnant or have a newborn. This is a Children’s Hospital of Los Angeles Research Study. Participating in this study is voluntary'
  post_template.content[:headline] = 'Contact us today!'
  post_template.content[:link_description] = 'Monetary compensation available'
  post_template.content[:call_to_action] = 'Learn More'
  post_template.content[:website_url] = 'https://clinicaltrials.keckmedicine.org/the-mamita-study-maternal-and-infant-nutrition'
  post_template.save

  post_template = PostTemplate.new
  post_template.experiment = experiment
  post_template.social_media_specification = SocialMediaSpecification.where(platform: :facebook, post_type: :ad, format: :single_image, placement: :news_feed)[0]
  post_template.content[:text] = 'Sugar and your baby’s health. Come join our free study that may help improve the health of Latino moms and their babies. This is a Children’s Hospital of Los Angeles Research Study. Participating in this study is voluntary.'
  post_template.content[:headline] = 'Get in touch today! '
  post_template.content[:link_description] = 'Monetary compensation available'
  post_template.content[:call_to_action] = 'Learn More'
  post_template.content[:website_url] = 'https://clinicaltrials.keckmedicine.org/the-mamita-study-maternal-and-infant-nutrition'
  post_template.save

  post_template = PostTemplate.new
  post_template.experiment = experiment
  post_template.social_media_specification = SocialMediaSpecification.where(platform: :facebook, post_type: :ad, format: :single_image, placement: :news_feed)[0]
  post_template.content[:text] = 'A chubby baby is a not necessarily a healthy baby. New free study for expecting Latinas and moms with newborns. This is a Children’s Hospital of Los Angeles Research Study. Participating in this study is voluntary.'
  post_template.content[:headline] = 'Contact us today!'
  post_template.content[:link_description] = 'Monetary incentives available '
  post_template.content[:call_to_action] = 'Contact Us'
  post_template.content[:website_url] = 'https://clinicaltrials.keckmedicine.org/the-mamita-study-maternal-and-infant-nutrition'
  post_template.save

  post_template = PostTemplate.new
  post_template.experiment = experiment
  post_template.social_media_specification = SocialMediaSpecification.where(platform: :facebook, post_type: :ad, format: :single_image, placement: :news_feed)[0]
  post_template.content[:text] = 'New study looks at health of Latinas and their babies. We’d like to hear from you if you’re a Latina expecting or have a newborn. This is a Children’s Hospital of Los Angeles Research Study. Participating in this study is voluntary.'
  post_template.content[:headline] = 'For better health!'
  post_template.content[:link_description] = 'Monetary compensation available'
  post_template.content[:call_to_action] = 'Learn More'
  post_template.content[:website_url] = 'https://clinicaltrials.keckmedicine.org/the-mamita-study-maternal-and-infant-nutrition'
  post_template.save
end

if experiment.post_templates.select{ |pt| pt.social_media_specification.platform == :google }.count == 0
  # Google post templates
  post_template = PostTemplate.new
  post_template.experiment = experiment
  post_template.social_media_specification = SocialMediaSpecification.where(platform: :google, post_type: :ad, format: :text, placement: :search_network)[0]
  post_template.content[:headline_1] = 'Sugar will affect your baby!'
  post_template.content[:headline_2] = 'Research for Latina moms'
  post_template.content[:headline_3] = 'Compensation available'
  post_template.content[:description_1] = 'Come join our free study if you are a pregnant or have a newborn.'
  post_template.content[:description_2] = 'This is a Children’s Hospital of Los Angeles Research Study. Compensation for volunteers.'
  post_template.content[:website_url] = 'https://clinicaltrials.keckmedicine.org/the-mamita-study-maternal-and-infant-nutrition'
  post_template.save

  post_template = PostTemplate.new
  post_template.experiment = experiment
  post_template.social_media_specification = SocialMediaSpecification.where(platform: :google, post_type: :ad, format: :text, placement: :search_network)[0]
  post_template.content[:headline_1] = "Sugar and your baby's health"
  post_template.content[:headline_2] = ' Research for Latina moms'
  post_template.content[:headline_3] = 'Compensation available'
  post_template.content[:description_1] = 'Join free study that may help improve the health of Latino moms and their babies.'
  post_template.content[:description_2] = 'This is a Children’s Hospital of Los Angeles Research Study. Participation is voluntary.'
  post_template.content[:website_url] = 'https://clinicaltrials.keckmedicine.org/the-mamita-study-maternal-and-infant-nutrition'
  post_template.save

  post_template = PostTemplate.new
  post_template.experiment = experiment
  post_template.social_media_specification = SocialMediaSpecification.where(platform: :google, post_type: :ad, format: :text, placement: :search_network)[0]
  post_template.content[:headline_1] = 'Chubby babies and health'
  post_template.content[:headline_2] = 'Research study for Latinas'
  post_template.content[:headline_3] = 'Home visits at no cost'
  post_template.content[:description_1] = 'A chubby baby is a not necessarily a healthy baby.'
  post_template.content[:description_2] = 'Join a Children’s Hospital of Los Angeles Research Study. Participation is voluntary.'
  post_template.content[:website_url] = 'https://clinicaltrials.keckmedicine.org/the-mamita-study-maternal-and-infant-nutrition'
  post_template.save

  post_template = PostTemplate.new
  post_template.experiment = experiment
  post_template.social_media_specification = SocialMediaSpecification.where(platform: :google, post_type: :ad, format: :text, placement: :search_network)[0]
  post_template.content[:headline_1] = 'New study for Latina moms'
  post_template.content[:headline_2] = "Learn more about babies health"
  post_template.content[:headline_3] = 'Home visits at no cost'
  post_template.content[:description_1] = 'Come join our free study if you are a pregnant or have a newborn.'
  post_template.content[:description_2] = 'This is a Children’s Hospital of Los Angeles Research Study. Compensation for volunteers.'
  post_template.content[:website_url] = 'https://clinicaltrials.keckmedicine.org/the-mamita-study-maternal-and-infant-nutrition'
  post_template.save
end

# Image pool
image_ids = Image.belonging_to(experiment).map(&:id).to_a
experiment.post_templates.each do | post_template |
  post_template.image_pool = image_ids
  post_template.save
end


# Seed MetroHealth post templates
# experiment = Experiment.where(name: "Ankylosing Spondylitis Survey")[0]

# # Facebook post templates
# if experiment.post_templates.select{ |pt| pt.social_media_specification.platform == :facebook }.count == 0
#   # Facebook post templates
#   post_template = PostTemplate.new
#   post_template.experiment = experiment
#   post_template.social_media_specification = SocialMediaSpecification.where(platform: :facebook, post_type: :ad, format: :single_image, placement: :news_feed)[0]
#   post_template.content[:text] = 'New nationwide study: Why some Americans experience more severe inflammatory back pain. Join our study if you are affected! Complete the survey and get a chance to win a reward.'
#   post_template.content[:headline] = 'Complete survey today!'
#   post_template.content[:link_description] = 'Your time is much appreciated.'
#   post_template.content[:call_to_action] = 'Learn More'
#   post_template.content[:website_url] = 'http://sc-ctsi.org/metrohealth/back-pain-study.html'
#   post_template.save

#   post_template = PostTemplate.new
#   post_template.experiment = experiment
#   post_template.social_media_specification = SocialMediaSpecification.where(platform: :facebook, post_type: :ad, format: :single_image, placement: :news_feed)[0]
#   post_template.content[:text] = 'Inflammatory back pain is a difficult disease to live with. Help us to better understand it and take this survey. You get a chance to win a reward.'
#   post_template.content[:headline] = 'Join our study today!'
#   post_template.content[:link_description] = 'Your time is much appreciated.'
#   post_template.content[:call_to_action] = 'Learn More'
#   post_template.content[:website_url] = 'http://sc-ctsi.org/metrohealth/back-pain-study.html'
#   post_template.save
  
#   post_template = PostTemplate.new
#   post_template.experiment = experiment
#   post_template.social_media_specification = SocialMediaSpecification.where(platform: :facebook, post_type: :ad, format: :single_image, placement: :news_feed)[0]
#   post_template.content[:text] = 'Tired of constant back pain that does not improve. Join nationwide study about inflammatory back pain to find out why some are more affected than others. You get a chance to win a gift card.'
#   post_template.content[:headline] = 'Take the survey today!'
#   post_template.content[:link_description] = 'Your help is much appreciated.'
#   post_template.content[:call_to_action] = 'Learn More'
#   post_template.content[:website_url] = 'http://sc-ctsi.org/metrohealth/back-pain-study.html'
#   post_template.save

#   post_template = PostTemplate.new
#   post_template.experiment = experiment
#   post_template.social_media_specification = SocialMediaSpecification.where(platform: :facebook, post_type: :ad, format: :single_image, placement: :news_feed)[0]
#   post_template.content[:text] = 'Back stiffness in the morning and difficulty moving. Sounds familiar? Nationwide study about inflammatory back pain looks at why it is worse for some people. Participate and get a chance to win a reward.'
#   post_template.content[:headline] = 'Take the survey today!'
#   post_template.content[:link_description] = 'Your time is much appreciated.'
#   post_template.content[:call_to_action] = 'Learn More'
#   post_template.content[:website_url] = 'http://sc-ctsi.org/metrohealth/back-pain-study.html'
#   post_template.save

#   post_template = PostTemplate.new
#   post_template.experiment = experiment
#   post_template.social_media_specification = SocialMediaSpecification.where(platform: :facebook, post_type: :ad, format: :single_image, placement: :news_feed)[0]
#   post_template.content[:text] = 'Please participate and take the survey if you’re affected by inflammatory back pain. Nationwide study looks at why it is worse for some people. You get a chance to win a reward.'
#   post_template.content[:headline] = 'Complete the survey today!'
#   post_template.content[:link_description] = 'Your time is much appreciated.'
#   post_template.content[:call_to_action] = 'Learn More'
#   post_template.content[:website_url] = 'http://sc-ctsi.org/metrohealth/back-pain-study.html'
#   post_template.save

#   post_template = PostTemplate.new
#   post_template.experiment = experiment
#   post_template.social_media_specification = SocialMediaSpecification.where(platform: :facebook, post_type: :ad, format: :single_image, placement: :news_feed)[0]
#   post_template.content[:text] = 'Why do some people have worse back pain or morning stiffness than others? Help us to find out if you are affected by inflammatory back pain and join nationwide research study. You get a chance to win a gift card.'
#   post_template.content[:headline] = 'Complete the survey today!'
#   post_template.content[:link_description] = 'Your help is much appreciated.'
#   post_template.content[:call_to_action] = 'Learn More'
#   post_template.content[:website_url] = 'http://sc-ctsi.org/metrohealth/back-pain-study.html'
#   post_template.save

#   post_template = PostTemplate.new
#   post_template.experiment = experiment
#   post_template.social_media_specification = SocialMediaSpecification.where(platform: :facebook, post_type: :ad, format: :single_image, placement: :news_feed)[0]
#   post_template.content[:text] = 'Why are Black patients more affected by inflammatory back pain than White folks? Nationwide study tries to find an answer. Help us find out and take our survey. You get a chance to win a gift card.'
#   post_template.content[:headline] = 'Complete the survey today!'
#   post_template.content[:link_description] = 'Your help is much appreciated.'
#   post_template.content[:call_to_action] = 'Learn More'
#   post_template.content[:website_url] = 'http://sc-ctsi.org/metrohealth/back-pain-study.html'
#   post_template.save
# end


# # Twitter post templates
# if experiment.post_templates.select{ |pt| pt.social_media_specification.platform == :twitter }.count == 0
#   post_template = PostTemplate.new
#   post_template.experiment = experiment
#   post_template.social_media_specification = SocialMediaSpecification.where(platform: :twitter, post_type: :organic, format: :tweet, placement: :timeline)[0]
#   post_template.content[:text] = 'New nationwide study: Why some Americans experience more severe inflammatory back pain. Join our study if you are affected! Complete the survey and get a chance to win a reward.'
#   post_template.content[:hashtags] = '#backpain #ankylosingspondylitis #MonsterPainInTheAS #sacroiliitis'
#   post_template.content[:website_url] = 'http://sc-ctsi.org/metrohealth/back-pain-study.html'
#   post_template.save

#   post_template = PostTemplate.new
#   post_template.experiment = experiment
#   post_template.social_media_specification = SocialMediaSpecification.where(platform: :twitter, post_type: :organic, format: :tweet, placement: :timeline)[0]
#   post_template.content[:text] = 'Inflammatory back pain is a difficult disease to live with. Help us to better understand it and take this survey. You get a chance to win a reward.'
#   post_template.content[:hashtags] = '#backpain #ankylosingspondylitis #MonsterPainInTheAS #sacroiliitis'
#   post_template.content[:website_url] = 'http://sc-ctsi.org/metrohealth/back-pain-study.html'
#   post_template.save

#   post_template = PostTemplate.new
#   post_template.experiment = experiment
#   post_template.social_media_specification = SocialMediaSpecification.where(platform: :twitter, post_type: :organic, format: :tweet, placement: :timeline)[0]
#   post_template.content[:text] = 'Tired of constant back pain that does not improve. Join nationwide study about inflammatory back pain to find out why some are more affected than others. You get a chance to win a gift card.'
#   post_template.content[:hashtags] = '#backpain #ankylosingspondylitis #MonsterPainInTheAS #sacroiliitis'
#   post_template.content[:website_url] = 'http://sc-ctsi.org/metrohealth/back-pain-study.html'
#   post_template.save

#   post_template = PostTemplate.new
#   post_template.experiment = experiment
#   post_template.social_media_specification = SocialMediaSpecification.where(platform: :twitter, post_type: :organic, format: :tweet, placement: :timeline)[0]
#   post_template.content[:text] = 'Back stiffness in the morning and difficulty moving. Sounds familiar? Nationwide study about inflammatory back pain looks at why it is worse for some people. Participate and get a chance to win a reward.'
#   post_template.content[:hashtags] = '#backpain #ankylosingspondylitis #MonsterPainInTheAS #sacroiliitis'
#   post_template.content[:website_url] = 'http://sc-ctsi.org/metrohealth/back-pain-study.html'
#   post_template.save

#   post_template = PostTemplate.new
#   post_template.experiment = experiment
#   post_template.social_media_specification = SocialMediaSpecification.where(platform: :twitter, post_type: :organic, format: :tweet, placement: :timeline)[0]
#   post_template.content[:text] = 'Please participate and take the survey if you’re affected by inflammatory back pain. Nationwide study looks at why it is worse for some people. You get a chance to win a reward.'
#   post_template.content[:hashtags] = '#backpain #ankylosingspondylitis #MonsterPainInTheAS #sacroiliitis'
#   post_template.content[:website_url] = 'http://sc-ctsi.org/metrohealth/back-pain-study.html'
#   post_template.save

#   post_template = PostTemplate.new
#   post_template.experiment = experiment
#   post_template.social_media_specification = SocialMediaSpecification.where(platform: :twitter, post_type: :organic, format: :tweet, placement: :timeline)[0]
#   post_template.content[:text] = 'Why do some people have worse back pain or morning stiffness than others? Help us to find out if you are affected by inflammatory back pain and join nationwide research study. You get a chance to win a gift card.'
#   post_template.content[:hashtags] = '#backpain #ankylosingspondylitis #MonsterPainInTheAS #sacroiliitis'
#   post_template.content[:website_url] = 'http://sc-ctsi.org/metrohealth/back-pain-study.html'
#   post_template.save

#   post_template = PostTemplate.new
#   post_template.experiment = experiment
#   post_template.social_media_specification = SocialMediaSpecification.where(platform: :twitter, post_type: :organic, format: :tweet, placement: :timeline)[0]
#   post_template.content[:text] = 'Why are Black patients more affected by inflammatory back pain than White folks? Nationwide study tries to find an answer. Help us find out and take our survey. You get a chance to win a gift card.'
#   post_template.content[:hashtags] = '#backpain #ankylosingspondylitis #MonsterPainInTheAS #sacroiliitis'
#   post_template.content[:website_url] = 'http://sc-ctsi.org/metrohealth/back-pain-study.html'
#   post_template.save
# end

