class PerspectiveClient
  def get_toxicity_score(comment)
    # @comments = Comment.where(toxicity_score: null)

# curl -H "Content-Type: application/json" --data '{comment: {text: "#{comment.content}"},languages: ["en"],requestedAttributes: {TOXICITY:{}} }' https://commentanalyzer.googleapis.com/v1alpha1/comments:analyze?key='AIzaSyBfCT_Irwq-RvcC9n1Cc9dQRkDt_9mTH8s'
  end
end