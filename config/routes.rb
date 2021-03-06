Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    omniauth_callbacks: 'users/omniauth_callbacks',
    registrations: 'users/registrations'
  }
  devise_scope :user do
    get 'addresses', to: 'users/registrations#new_address'
    post 'addresses', to: 'users/registrations#create_address'
    delete 'destroy_user_session', to: 'users/sessions#destroy'
  end

  root to: "products#index"

  resources :products do
    resources :comments, only: :create

    collection do
      get  'purchase/:id'=>  'products#purchase', as: 'purchase'
      post 'pay/:id'=>   'products#pay', as: 'pay'
      get "category"
      get "search"
      get "previous"
      get "next"
      get "product_search"
      get "conditional_search"
    end

    member do
      get 'categoryindex'
    end
    
  end

  resources :cards, only: [:index, :new, :create, :destroy]
  
  resources :likes, only: [:index, :create, :destroy]

  resources :users, only: [:show] do
    collection do
      get "rogout"
    end
  end

end