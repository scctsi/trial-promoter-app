Rails.application.routes.draw do
  root 'campaigns#index'
  
  # Campaigns
  resources :campaigns do
    member do
    end
    collection do
    end
  end
  
  # App settings
  namespace :admin do
    resources :settings
  end
end
