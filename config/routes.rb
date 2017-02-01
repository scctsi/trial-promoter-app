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
      get 'create_messages(.:format)', to: 'experiments#create_messages'
      get 'create_analytics_file_todos', to: 'experiments#create_analytics_file_todos'
    end
    collection do
      get 'calculate_message_count', to: 'experiments#calculate_message_count', constraints: lambda { |req| req.format == :json }
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
      post 'tag_images', to: 'images#tag_images', constraints: lambda { |req| req.format == :json }
    end
  end

  # Analytics files
  resources :analytics_files do
    member do
      patch 'update', to: 'analytics_files#update', constraints: lambda { |req| req.format == :json }
    end
  end

  # Social media profiles
  resources :social_media_profiles do
  end
end
