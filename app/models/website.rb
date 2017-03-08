# == Schema Information
#
# Table name: websites
#
#  id         :integer          not null, primary key
#  name       :string(1000)
#  url        :string(2000)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require "addressable/uri"

class Website < ActiveRecord::Base
  acts_as_ordered_taggable
  acts_as_ordered_taggable_on :experiments

  validates :url, presence: true

  has_many :messages, as: :promotable
  
  scope :belonging_to, ->(experiment) { tagged_with(experiment.to_param, on: :experiments) }
  
  def url=(url)
    if url.nil?
      self[:url] = nil if url.nil?
    else
      self[:url] = canonicalize(url)
    end
  end
  
  def url
    return nil if self[:url].nil?
    return canonicalize(self[:url])
  end
  
  private
  def canonicalize(url)
    # REF: http://stackoverflow.com/questions/11760831/in-rails-how-do-i-determine-if-two-urls-are-equal
    uri = Addressable::URI.parse(url)
    uri.scheme = "http" if uri.scheme.blank?
    host = uri.host.sub(/\www\./, '') if uri.host.present?
    path = (uri.path.present? && uri.host.blank?) ? uri.path.sub(/\www\./, '') : uri.path
    (uri.scheme.to_s + "://" + host.to_s + path.to_s).downcase
  end
end
