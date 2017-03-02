require 'rails_helper'

RSpec.describe TagMatcher do
  before do
    @tag_matcher = TagMatcher.new
    @websites = create_list(:website, 3)
    @message_templates = create_list(:message_template, 3)
  end

  it 'finds an instance of a specified class that is tagged with all the specified tags' do
    @websites[0].tag_list = ['tag-1']
    @websites[1].tag_list = ['tag-1', 'tag-2']
    @websites[2].tag_list = ['tag-1', 'tag-2', 'tag-3']
    @websites.each { |website| website.save }

    tagged_websites = @tag_matcher.find(Website, ['tag-1', 'tag-2', 'tag-3'])

    expect(tagged_websites.length).to eq(1)
    expect(tagged_websites[0].tag_list).to include('tag-1', 'tag-2', 'tag-3')
  end

  it 'finds all instances of a specified class that is tagged with all the specified tags' do
    @websites[0].tag_list = ['tag-1']
    @websites[1].tag_list = ['tag-1', 'tag-2', 'tag-3']
    @websites[2].tag_list = ['tag-1', 'tag-2', 'tag-3']
    @websites.each { |website| website.save }

    tagged_websites = @tag_matcher.find(Website, ['tag-1', 'tag-2', 'tag-3'])

    expect(tagged_websites.length).to eq(2)
    tagged_websites.each { |tagged_website| expect(tagged_website.tag_list).to include('tag-1', 'tag-2', 'tag-3') }
  end

  it 'finds all instances of a specified class that is tagged with all the specified tags and includes additional tags' do
    @websites[0].tag_list = ['tag-1']
    @websites[1].tag_list = ['tag-1', 'tag-2', 'tag-3']
    @websites[2].tag_list = ['tag-1', 'tag-2', 'tag-3', 'tag-4', 'tag-5']
    @websites.each { |website| website.save }

    tagged_websites = @tag_matcher.find(Website, ['tag-1', 'tag-2', 'tag-3'])

    expect(tagged_websites.length).to eq(2)
    tagged_websites.each { |tagged_website| expect(tagged_website.tag_list).to include('tag-1', 'tag-2', 'tag-3') }
  end

  it 'returns an empty array if no instances of the specified class contain all the tags' do
    @websites[0].tag_list = ['tag-1']
    @websites[1].tag_list = ['tag-1', 'tag-2']
    @websites[2].tag_list = ['tag-1', 'tag-3']
    @websites.each { |website| website.save }

    tagged_websites = @tag_matcher.find(Website, ['tag-1', 'tag-2', 'tag-3'])

    expect(tagged_websites.length).to eq(0)
  end

  describe 'matching' do
    it 'acts_as_taggable_on correctly matches when match_all is true' do
      @websites[0].tag_list = ['tag-1']
      @websites[1].tag_list = ['tag-2', 'tag-3']
      @websites[2].tag_list = ['tag-1', 'tag-2', 'tag-3', 'tag-4', 'tag-5']
      @websites.each { |website| website.save }

      found_websites = Website.tagged_with(['tag-1'], :match_all => true)

      expect(found_websites.length).to eq(1)
    end

    it 'matches all objects whose tags are a subset of a given set of tags' do
      @websites[0].tag_list = ['tag-1']
      @websites[1].tag_list = ['tag-2', 'tag-3']
      @websites[2].tag_list = ['tag-1', 'tag-2', 'tag-3', 'tag-4', 'tag-5']
      @websites.each { |website| website.save }
      images = create_list(:image, 6)
      images[0].tag_list = ['tag-1']
      images[1].tag_list = ['tag-2', 'tag-3']
      images[2].tag_list = ['tag-4', 'tag-5']
      images[3].tag_list = ['tag-3', 'tag-4']
      images[4].tag_list = ['tag-5', 'tag-6']
      images[5].tag_list = ['tag-7', 'tag-8']
      images.each { |image| image.save }

      matched_images = @tag_matcher.match(images, @websites[2].tag_list)

      expect(matched_images.length).to eq(4)
    end

    it 'includes all objects whose tags are the same as a given set of tags' do
      @websites[0].tag_list = ['tag-1']
      @websites[1].tag_list = ['tag-2', 'tag-3']
      @websites[2].tag_list = ['tag-1', 'tag-2', 'tag-3', 'tag-4', 'tag-5']
      @websites.each { |website| website.save }
      images = create_list(:image, 6)
      images[0].tag_list = ['tag-1']
      images[1].tag_list = ['tag-2', 'tag-3']
      images[2].tag_list = ['tag-4', 'tag-5']
      images[3].tag_list = ['tag-3', 'tag-4']
      images[4].tag_list = ['tag-5', 'tag-6']
      images[5].tag_list = ['tag-1', 'tag-2', 'tag-3', 'tag-4', 'tag-5']
      images.each { |image| image.save }

      matched_images = @tag_matcher.match(images, @websites[2].tag_list)

      expect(matched_images.length).to eq(5)
    end

    it 'returns all objects if all objects match the given set of tags' do
      @message_templates[0].tag_list = ['tag-1', 'tag-2', 'tag-3']
      @message_templates[0].save
      @websites[0].tag_list = ['tag-1', 'tag-2', 'tag-3']
      @websites[1].tag_list = ['tag-1', 'tag-2', 'tag-3']
      @websites[2].tag_list = ['tag-1', 'tag-2', 'tag-3']
      @websites.each { |website| website.save }

      matched_websites = @tag_matcher.match(@websites, @message_templates[0].tag_list)

      expect(matched_websites.length).to eq(3)
    end

    it 'restricts the matching only to the passed in tagged objects' do
      @websites[0].tag_list = ['tag-1']
      @websites[1].tag_list = ['tag-2', 'tag-3']
      @websites[2].tag_list = ['tag-1', 'tag-2', 'tag-3', 'tag-4', 'tag-5']
      @websites.each { |website| website.save }
      images = create_list(:image, 6)
      images[0].tag_list = ['tag-1']
      images[1].tag_list = ['tag-2', 'tag-3']
      images[2].tag_list = ['tag-4', 'tag-5']
      images[3].tag_list = ['tag-3', 'tag-4']
      images[4].tag_list = ['tag-5', 'tag-6']
      images[5].tag_list = ['tag-7', 'tag-8']
      images.each { |image| image.save }

      matched_images = @tag_matcher.match(images[0..2], @websites[2].tag_list)

      expect(matched_images.length).to eq(3)
    end
  end

  it 'returns the distinct tag list for a collection of tagged objects' do
    @websites[0].tag_list = ['tag-1']
    @websites[1].tag_list = ['tag-2', 'tag-3']
    @websites[2].tag_list = ['tag-1', 'tag-2', 'tag-3', 'tag-4', 'tag-5']

    distinct_tag_list = @tag_matcher.distinct_tag_list(@websites)

    expect(distinct_tag_list.count).to eq(5)
    expect(distinct_tag_list).to include('tag-1', 'tag-2', 'tag-3', 'tag-4', 'tag-5')
  end

  it 'does not return nil if there are no duplicates in the tagged objects' do
    @websites[0].tag_list = ['tag-1']
    @websites[1].tag_list = ['tag-2', 'tag-3']

    distinct_tag_list = @tag_matcher.distinct_tag_list(@websites)

    expect(distinct_tag_list.count).to eq(3)
    expect(distinct_tag_list).to include('tag-1', 'tag-2', 'tag-3')
  end
end