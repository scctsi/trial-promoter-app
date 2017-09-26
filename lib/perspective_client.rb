class PerspectiveClient
  def self.get_toxicity_score(comment)
    access_token = Setting[:google_perspective_api_key]
    "Content-Type: application/json" --data '{comment: {text: "#{comment.comment_text}"},languages: ["en"],requestedAttributes: {TOXICITY:{}} }' https://commentanalyzer.googleapis.com/v1alpha1/comments:analyze?key=access_token
  end
end