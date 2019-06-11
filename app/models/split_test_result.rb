class SplitTestResult < ActiveRecord::Base
  belongs_to :split_test
  validates :split_test, presence: true
  belongs_to :winning_variation, class_name: 'Post'
  belongs_to :losing_variation, class_name: 'Post'
end
