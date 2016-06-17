Shoppe::Engine.routes.draw do
  get 'attachment/:id/:filename.:extension' => 'attachments#show'

  resources :customers do
    post :search, on: :collection
    resources :addresses
  end

  resources :blog_posts, except: %w(show)
  post  '/posts/preview' => 'posts#preview', as: :post_preview
  patch '/posts/preview' => 'posts#preview'

  resources :product_categories do
    resources :localisations, controller: 'product_category_localisations'
    collection do
      put :positions
    end
  end
  resources :products do
    resources :variants do
      collection do
        put :positions
      end
    end
    resources :localisations, controller: 'product_localisations'
    collection do
      get :import
      post :import
      put :positions
    end
  end
  resources :orders do
    collection do
      post :search
    end
    member do
      post :accept
      post :reject
      post :ship
      get :despatch_note
      post :checkout
      get :xls
    end
    resources :payments, only: [:create, :destroy] do
      match :refund, on: :member, via: [:get, :post]
    end
  end
  resources :stock_level_adjustments, only: [:index, :create]
  resources :delivery_services do
    resources :delivery_service_prices
  end
  resources :tax_rates
  resources :users
  resources :countries
  resources :attachments, only: :destroy

  get 'settings' => 'settings#edit'
  post 'settings' => 'settings#update'

  get 'login' => 'sessions#new'
  post 'login' => 'sessions#create'

  get 'login/reset' => 'password_resets#new'
  post 'login/reset' => 'password_resets#create'

  delete 'logout' => 'sessions#destroy'

  get 'reset' => 'dashboard#reset', as: :reset_cache

  root to: 'dashboard#home'
end
