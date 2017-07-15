# == Schema Information
#
# Table name: comments
#
#  id                   :integer          not null, primary key
#  message_date         :date
#  message              :text
#  comment_date         :date
#  comment_text         :text
#  commentator_username :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  message_id           :string
#

class Comment < ActiveRecord::Base
  belongs_to :message
end
