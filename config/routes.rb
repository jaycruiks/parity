Rails.application.routes.draw do
  namespace :admin do
    resources :orders
    resources :order_items
    resources :payments
    resources :products
    resources :withdrawals
    resources :merchant_settings

    root to: "orders#index"
  end

  resources :products, only: [ :index, :show ]

  resource :cart, only: [ :show ] do
    post "add/:product_id", to: "carts#add", as: :add
    delete "remove/:product_id", to: "carts#remove", as: :remove
  end

  resources :orders, only: [ :new, :create, :show ] do
    member do
      get :payment_status
    end
    collection do
      get :lookup
      get :search
    end
  end

  namespace :webhooks do
    post "mural_pay", to: "mural_pay#create"
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "products#index"
end
