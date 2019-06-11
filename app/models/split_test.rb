class SplitTest < ActiveRecord::Base
  belongs_to :experiment
  validates :experiment, presence: true
  belongs_to :variation_a, class_name: 'Post'
  validates :variation_a, presence: true
  belongs_to :variation_b, class_name: 'Post'
  validates :variation_b, presence: true
  has_many :results, class_name: 'SplitTestResult'
  
  def self.update_split_tests(experiment)
    if experiment.split_tests.count == 0
      split_test = SplitTest.new(experiment: experiment, variation_a: experiment.posts[0], variation_b: experiment.posts[1])
      split_test.save
    end
  end
end
