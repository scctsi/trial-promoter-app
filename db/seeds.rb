# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Seed Facebook specifications
specifications = SocialMediaSpecification.where(platform: :facebook, post_type: :ad, format: :single_image, placement: :news_feed)

if specifications.count == 0
  specification = SocialMediaSpecification.new
  
  specification.platform = :facebook
  specification.post_type = :ad
  specification.format = :single_image
  specification.placement = :news_feed
  
  specification.save
end

# Seed some post templates for Facebook news feed ads
if PostTemplate.count == 0
  PostTemplate.destroy_all 
  
  experiment = Experiment.where(name: "Filipino Family Health Initiative: The Incredible Years for Parents of School Age Children")[0]
  
  post_template = PostTemplate.new
  post_template.experiment = experiment
  post_template.social_media_specification = SocialMediaSpecification.first
  post_template.content[:text] = 'Give your children the skills they’ll need to tackle life’s toughest challenges. Come join a community study for parents of Filipino kids 8-12.'
  post_template.content[:headline] = 'Contact her today!'
  post_template.content[:link_description] = 'Monetary incentives available'
  post_template.content[:call_to_action] = 'Learn More'
  post_template.content[:website_url] = 'http://www.filipinofamilyhealth.com/'
  post_template.save
  
  post_template = PostTemplate.new
  post_template.experiment = experiment
  post_template.social_media_specification = SocialMediaSpecification.first
  post_template.content[:text] = 'How important is the academic and social success of your child to you?  Come join a community study led by Dr. Joyce Javier that may help improve the well-being of Filipino youth.'
  post_template.content[:headline] = 'Get in touch today!'
  post_template.content[:link_description] = 'Monetary incentives available'
  post_template.content[:call_to_action] = 'Learn More'
  post_template.content[:website_url] = 'http://www.filipinofamilyhealth.com/'
  post_template.save
  
  post_template = PostTemplate.new
  post_template.experiment = experiment
  post_template.social_media_specification = SocialMediaSpecification.first
  post_template.content[:text] = 'Suicide is the leading cause of death among Asian and Pacific Islander teens in the U.S.? Come join a community study led by Dr. Joyce Javier to learn how to raise mentally strong kids.'
  post_template.content[:headline] = 'Sign up today! It’s free.'
  post_template.content[:link_description] = 'Monetary incentives available'
  post_template.content[:call_to_action] = 'Contact Us'
  post_template.content[:website_url] = 'http://www.filipinofamilyhealth.com/'
  post_template.save
  
  post_template = PostTemplate.new
  post_template.experiment = experiment
  post_template.social_media_specification = SocialMediaSpecification.first
  post_template.content[:text] = 'The majority of college students are not prepared to deal with disappointment, anxiety, and loneliness. Learn how to best prepare your child through this community study. For parents with kids 8-12 years.'
  post_template.content[:headline] = 'Sign up today! It’s free.'
  post_template.content[:link_description] = 'Monetary incentives available '
  post_template.content[:call_to_action] = 'Contact Us'
  post_template.content[:website_url] = 'http://www.filipinofamilyhealth.com/'
  post_template.save
end