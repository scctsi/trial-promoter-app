class TagMatcher
  def find(class_with_tags, tag_list)
    class_with_tags.send(:tagged_with, tag_list)
  end

  def match(tagged_objects, tag_list)
    matches = []
    tagged_objects.each do |t_o|
      p t_o.tag_list
    end

    (1..tag_list.length).each do |combination_length|
      tag_list.combination(combination_length).to_a.each do |tag_combination|
        found_objects = tagged_objects[0].class.send(:tagged_with, tag_combination, :match_all => true)
        found_objects = found_objects.select{ |found_object| tagged_objects.include?(found_object) }
        matches.concat(found_objects.to_a) if found_objects.length > 0
      end
    end

    matches
  end

  def distinct_tag_list(tagged_objects)
    calculated_tag_list = []

    tagged_objects.each do |tagged_object|
      calculated_tag_list.concat(tagged_object.tag_list)
    end
    calculated_tag_list.uniq
  end
end