Rails.application.routes.draw do
  # Order routes by frequency
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :clients, only: [] do
      resources :buildings, only: [ :index, :create, :update ]
    end
  end

  get "welcome/index"

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root "welcome#index"
end
