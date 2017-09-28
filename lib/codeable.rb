module Codeable
  def map_codes(code_object) 
    if code_object == []
      self.codes = {}
    else
      hash = {}
      code_object.each do |code_pair|
        key_value = code_pair.split(':') 
        hash[key_value[0]] = key_value[1] 
      end
      self.codes = hash
    end
    save
  end
end