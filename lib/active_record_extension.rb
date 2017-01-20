# REF: http://stackoverflow.com/questions/2328984/rails-extending-activerecordbase
module ActiveRecordExtension
  extend ActiveSupport::Concern

  # Add your instance methods here
  def symbolize_array_items(array)
    # Convert an array of strings to an array of symbols.
    # Remove any blank string first.
    return array.select{ |item| !item.blank? }.map(&:to_sym) if !array.nil?
    nil
  end
end

# Include the extension 
ActiveRecord::Base.send(:include, ActiveRecordExtension)