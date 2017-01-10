Rails.application.routes.draw do
  devise_for :users
  get 'social_media_profiles/sync_with_buffer'

  root 'home#index'

  # Campaigns
  resources :campaigns do
  end
  
  # Experiments
  resources :experiments, shallow: true do
    member do
      get 'parameterized_slug', to: 'experiments#parameterized_slug', constraints: lambda { |req| req.format == :json }
    end
    member do
      get 'create_messages', to: 'experiments#create_messages'
    end
    
    resources :message_generation_parameter_sets
  end
  
  # Clinical trials
  resources :clinical_trials do
  end
  
  # Message templates
  resources :message_templates do
    collection do
      get :import
    end
  end

  # Messages
  resources :messages do
    collection do
      get :generate
    end
  end

  # Websites
  resources :websites do
  end
  
  # App settings
  namespace :admin do
    resources :settings
  end
  
  # Images
  resources :images do
    member do
      post 'create', to: 'images#create', constraints: lambda { |req| req.format == :json }
    end
    collection do
      post :import
    end
  end
  
end
