class Post < ActiveRecord::Base
  belongs_to :experiment
  validates :experiment, presence: true
  belongs_to :post_template
  validates :post_template, presence: true
  
  def to_param
    "#{experiment.to_param}-post-#{id.to_s}"
  end
end

