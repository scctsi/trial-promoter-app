class TagMatcher
  def find(class_with_tags, tag_list)
    class_with_tags.send(:tagged_with, tag_list)
  end
  
  def match(class_with_tags, tag_list)
    matches = []
    
    (1..tag_list.length).each do |combination_length|
      tag_list.combination(combination_length).to_a.each do |tag_combination|
        found_instances = class_with_tags.send(:tagged_with, tag_combination, :match_all => true)
        matches.concat(found_instances.to_a) if found_instances.length > 0
      end
    end

    matches
  end
  
  def distinct_tag_list(tagged_objects)
    calculated_tag_list = []
    
    tagged_objects.each do |tagged_object|
      calculated_tag_list.concat(tagged_object.tag_list)
    end
    
    calculated_tag_list.uniq!
  end
end