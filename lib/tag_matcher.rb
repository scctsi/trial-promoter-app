class TagMatcher
  def find(class_with_tags, tag_list)
    class_with_tags.send(:tagged_with, tag_list)
  end

  def match(tagged_objects, tag_list)
    matches = []

    (1..tag_list.length).each do |combination_length|
      tag_list.combination(combination_length).to_a.each do |tag_combination|
        found_objects = tagged_objects.select{ |tagged_object| tagged_object.tag_list == tag_combination }
        matches.concat(found_objects) if found_objects.length > 0
      end
    end

    matches.uniq
  end

  def distinct_tag_list(tagged_objects)
    calculated_tag_list = []

    tagged_objects.each do |tagged_object|
      calculated_tag_list.concat(tagged_object.tag_list)
    end
    calculated_tag_list.uniq
  end
end