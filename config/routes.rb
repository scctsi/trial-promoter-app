Rails.application.routes.draw do
  root 'campaigns#index'
  
  # Campaigns
  resources :campaigns do
  end
  
  # Experiments
  resources :experiments do
  end
  
  # Clinical trials
  resources :clinical_trials do
  end
  
  # Message templates
  resources :message_templates do
  end
  
  # App settings
  namespace :admin do
    resources :settings
  end
end
