Rails.application.routes.draw do
  resources :products, only: [ :index, :show ]

  resource :cart, only: [ :show ] do
    post "add/:product_id", to: "carts#add", as: :add
    delete "remove/:product_id", to: "carts#remove", as: :remove
  end

  resources :orders, only: [ :new, :create, :show ]

  get "up" => "rails/health#show", as: :rails_health_check

  root "products#index"
end
