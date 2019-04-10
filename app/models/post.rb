class Post < ActiveRecord::Base
  belongs_to :experiment
  validates :experiment, presence: true
  belongs_to :post_template
  validates :post_template, presence: true
  store :content, coder: JSON
  has_many :metrics

  def to_param
    "#{experiment.to_param}-post-#{id}"
  end
  
  def self.find_by_param(param)
    id = param[(param.rindex('-') + 1)..-1]
    Post.find(id)
  end
end

