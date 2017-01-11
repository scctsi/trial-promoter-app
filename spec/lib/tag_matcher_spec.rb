require 'rails_helper'

RSpec.describe TagMatcher do
  before do
    @tag_matcher = TagMatcher.new
  end
  
  it 'finds an instance of a specified class that contains all the specified tags' do
    websites = create_list(:website, 3)
    websites[0].tag_list.add('tag-1')
    websites[1].tag_list.add('tag-1', 'tag-2')
    websites[2].tag_list.add('tag-1', 'tag-2', 'tag-3')
    websites.each { |website| website.save }
    
    tagged_websites = @tag_matcher.find(Website, ['tag-1', 'tag-2', 'tag-3'])
    
    expect(tagged_websites.length).to eq(1)
    expect(tagged_websites[0].tag_list).to include('tag-1', 'tag-2', 'tag-3')
  end

  it 'finds all instances of a specified class that contains all the specified tags' do
    websites = create_list(:website, 3)
    websites[0].tag_list.add('tag-1')
    websites[1].tag_list.add('tag-1', 'tag-2', 'tag-3')
    websites[2].tag_list.add('tag-1', 'tag-2', 'tag-3')
    websites.each { |website| website.save }
    
    tagged_websites = @tag_matcher.find(Website, ['tag-1', 'tag-2', 'tag-3'])
    
    expect(tagged_websites.length).to eq(2)
    tagged_websites.each { |tagged_website| expect(tagged_website.tag_list).to include('tag-1', 'tag-2', 'tag-3') }
  end

  it 'finds all instances of a specified class that contains all the specified tags and include additional tags' do
    websites = create_list(:website, 3)
    websites[0].tag_list.add('tag-1')
    websites[1].tag_list.add('tag-1', 'tag-2', 'tag-3')
    websites[2].tag_list.add('tag-1', 'tag-2', 'tag-3', 'tag-4', 'tag-5')
    websites.each { |website| website.save }
    
    tagged_websites = @tag_matcher.find(Website, ['tag-1', 'tag-2', 'tag-3'])
    
    expect(tagged_websites.length).to eq(2)
    tagged_websites.each { |tagged_website| expect(tagged_website.tag_list).to include('tag-1', 'tag-2', 'tag-3') }
  end

  it 'returns an empty array if no instances of the specified class contain all the tags' do
    websites = create_list(:website, 3)
    websites[0].tag_list.add('tag-1')
    websites[1].tag_list.add('tag-1', 'tag-2')
    websites[2].tag_list.add('tag-1', 'tag-3')
    websites.each { |website| website.save }
    
    tagged_websites = @tag_matcher.find(Website, ['tag-1', 'tag-2', 'tag-3'])
    
    expect(tagged_websites.length).to eq(0)
  end
  
  it 'finds all instances of a specified class whose tags are included in the tags for a tagged instance (of another class)' do
    websites = create_list(:website, 3)
    websites[0].tag_list.add('tag-1')
    websites[1].tag_list.add('tag-2', 'tag-3')
    websites[2].tag_list.add('tag-1', 'tag-2', 'tag-3', 'tag-4', 'tag-5')
    websites.each { |website| website.save }
    images = create_list(:image, 6)
    images[0].tag_list.add('tag-1')
    images[1].tag_list.add('tag-2', 'tag-3')
    images[2].tag_list.add('tag-4', 'tag-5')
    images[3].tag_list.add('tag-3', 'tag-4')
    images[4].tag_list.add('tag-5', 'tag-6')
    images[5].tag_list.add('tag-7', 'tag-8')
    images.each { |image| image.save }

    matched_images = @tag_matcher.match(Image, websites[2])
    
    expect(matched_images.length).to eq(4)
  end
end