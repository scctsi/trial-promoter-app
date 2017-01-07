class TrialPromoter
  SUPPORTED_NETWORKS = [:facebook, :instagram, :twitter]
  # TODO: Add medium and which networks support which? As well as the capability for instance
  # facebook - organic - Auto
  # facebook - ad - semi-auto
  # twitter - ad - generation only
  
  def self.supports?(social_network)
    social_network = social_network.to_s.strip.downcase.to_sym  
    
    SUPPORTED_NETWORKS.include?(social_network)
  end
end