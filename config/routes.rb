Rails.application.routes.draw do
  root 'campaigns#index'
  
  resources :campaigns do
    member do
    end
    collection do
    end
  end
  
  resources :settings do
    member do
    end
    collection do
    end
  end
end
