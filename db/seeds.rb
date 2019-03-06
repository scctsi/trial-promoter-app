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