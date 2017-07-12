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
      get 'send_to_buffer', to: 'experiments#send_to_buffer'
      get 'create_analytics_file_todos', to: 'experiments#create_analytics_file_todos'
      get 'correctness_analysis', to: 'experiments#correctness_analysis'
      get 'messages_page', to: 'experiments#messages_page'
    end
    resources :message_generation_parameter_sets
  end

  # Clinical trials
  resources :clinical_trials do
  end

  # Message templates
  resources :message_templates do
    member do
      post 'get_image_selections', to: 'message_templates#get_image_selections', constraints: lambda { |req| req.format == :json }
      post 'add_image_to_image_pool', to: 'message_templates#add_image_to_image_pool', constraints: lambda { |req| req.format == :json }
      post 'remove_image_from_image_pool', to: 'message_templates#remove_image_from_image_pool', constraints: lambda { |req| req.format == :json }
    end
    collection do
      get :import
    end
  end

  # Messages
  resources :messages do
    collection do
      get :generate
    end
    member do
      post 'edit_campaign_id', to: 'messages#edit_campaign_id'
      get 'new_campaign_id', to: 'messages#new_campaign_id'
    end
  end

  # App settings
  namespace :admin do
    resources :settings
  end

  # Images
  resources :images do
    collection do
      post :import
      get :check_validity_for_instagram_ads
      post :add
    end
  end

  # Analytics files
  resources :analytics_files do
    member do
      patch 'update', to: 'analytics_files#update', constraints: lambda { |req| req.format == :json }
    end
    collection do
      get 'process_all_files', to: 'analytics_files#process_all_files'
    end
  end

  # Social media profiles
  resources :social_media_profiles do
  end

  # Data dictionaries
  resources :data_dictionaries do
  end
end
