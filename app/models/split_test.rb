class SplitTest < ActiveRecord::Base
  belongs_to :experiment
  validates :experiment, presence: true
  belongs_to :variation_a, class_name: 'Post'
  validates :variation_a, presence: true
  belongs_to :variation_b, class_name: 'Post'
  validates :variation_b, presence: true
end
