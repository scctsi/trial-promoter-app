require 'net/http'
require 'uri'

class PerspectiveClient
  def self.calculate_toxicity_score(text)
    text = text.gsub(/"/, "'")
    access_token = Setting[:google_perspective_api_key]

    uri = URI.parse("https://commentanalyzer.googleapis.com/v1alpha1/comments:analyze?key=#{access_token}")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request.body = "{comment: {text: \"#{text}\"},languages: [\"en\"],requestedAttributes: {TOXICITY:{}} }"
     
    req_options = {
      use_ssl: uri.scheme == "https"
    }
    
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    return JSON.parse(response.body)["attributeScores"]["TOXICITY"]["summaryScore"]["value"].round(2).to_s 
  end
end