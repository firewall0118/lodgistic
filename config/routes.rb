 Lodgistics::Application.routes.draw do
  require 'sidekiq/web'

  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    # registrations: 'users/registrations',
    passwords: 'users/passwords',
    confirmations: 'users/confirmations',
    registraions: 'users/registrations'
  }
  # , skip: [:registrations]
  if Rails.env.production?
    %w( 404 ).each do |code|
      get code, to: "errors#show", code: code
    end
  end

  namespace :corporate do
    root to: 'pages#dashboard'
    resources :reports
    resources :settings, only: [:index]
    resources :property_connections, only: [:show, :update]
    resources :purchase_requests, only: [:edit, :update], path: 'requests'
    get '/spend_budget_by_hotel_data' => 'pages#spend_budget_by_hotel', as: 'spend_budget_by_hotel_data'
  end

  resource :corporate_connections

  get :spend_vs_budgets_data, to: 'pages#spend_vs_budgets_data'

  devise_scope :user do
    # authenticated :user, lambda{|user| binding.pry; user.corporate? } do
    #   root to: redirect('/corporate')
    # end
    authenticated :user do
      root 'pages#home', as: :authenticated_root
    end

    unauthenticated do
      root 'users/sessions#new', as: :unauthenticated_root
      #match '*unmatched', via: [:get], to: redirect('/') 
    end
    namespace :users, as: :user do
      put "/confirm" => "confirmations#confirm", as: :confirm
      put '/switch_current_property', to: 'sessions#switch_current_property', as: :switch_current_property
      resource :registration, only: [:edit, :update]
    end
  end
  resources :property_settings, path: 'settings', only: [:index]
  # resources :categories, controller: 'tags'
  # resources :lists, controller: 'tags'
  # resources :locations, controller: 'tags'
  resources :categories, :locations, :lists do
    get 'rearrange', on: :member
    get 'destroy', on: :collection, path: 'destroy', as: 'destroy'
  end  
  resources :items do
    collection do
      get 'start_order'
      get 'edit_multiple_tags'
      put 'update_multiple_tags'
      get :new_import
      post :import
      get 'destroy', path: 'destroy', as: 'destroy'
    end
  end
  resources :permissions, except: :show do
    get :subjects, on: :collection
  end
  resources :properties, only: [:show, :index, :update]
    resources :tags do
    get 'rearrange', on: :member
  end
  resources :purchase_orders, except: [:edit, :new, :create], path: 'orders' do
    member do
      post :send_fax, to: 'fax#create'
      get :fax_status, to: 'fax#show'
      post :update_fax, to: 'fax#update'
      post :send_email, to: 'email#create'
      post :send_vpt, to: 'vpt#create'
      get :print
    end
  end
  resources :purchase_receipts, only: [:new, :create], path: 'receipts'
  resources :purchase_requests, path: 'requests' do
    member do
      get :inventory_print
    end
  end
  resources :users do
    member do
      get :change_password
    end
  end
  resources :messages
  resources :budgets

  resources :reports do
    member do
      put :favorite
    end
    collection do
      get :favorites
      #get *Report.pluck(:permalink).map{|p| p + '_data'} if Report.any?
      get :vendor_spend_data
      get :category_spend_data
      get :items_consumption_data
      get :item_orders_chart_data
      get :items_spend_data
      get :item_price_variance_data
      get :inventory_vs_ordering_data
    end
  end


  resources :vendors
  resources :room_types
  resources :departments
  resources :notifications

  resources :join_hotel_invitations do
    get 'accept', on: :member
  end

  post 'punchout/:property_id/:vendor_id/shopping_cart', to: "punchout#shopping_cart", as: 'punchout_shopping_cart'
  get 'punchout/:property_id/:vendor_id', to: "punchout#create", as: 'start_punchout'

  get 'analytics', to: "analytics#index"
  get 'forecasts/(week/:year/:month/:day)', to: "forecasts#index", as: "forecasts"
  put 'forecast', to: "forecasts#update", as: "update_forecast"

  get '/fax', to: 'fax#show'
  post '/fax', to: 'fax#create'
  post '/phaxio', to: 'fax#update'
  get 'dashboard', to: 'pages#dashboard', :as => :dashboard
  get 'pages/home'
  # authenticated :user do
  #   root to: 'pages#dashboard'
  # end

  #root to: 'users/sessions#new'  
  if Rails.env.development?
    mount DevisePreview => 'devise_view'
    mount MailerPreview => 'mailer_view'
    mount Sidekiq::Web, at: '/sidekiq'
  end

end
