class ImageReplacementAction < ActiveRecord::Base
  serialize :replacements, Hash
end
