Rails.application.routes.draw do
  root 'home#index'
  
  # Campaigns
  resources :campaigns do
  end
  
  # Experiments
  resources :experiments, shallow: true do
    resources :message_generation_parameter_sets
  end
  
  # Clinical trials
  resources :clinical_trials do
  end
  
  # Message templates
  resources :message_templates do
  end

  # Websites
  resources :websites do
  end
  
  # App settings
  namespace :admin do
    resources :settings
  end
end
