Rails.application.routes.draw do
  
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  post 'signup', to: 'authentication#signup'
  post 'login', to: 'authentication#login'

  # User Details routes
  resources :users, only: [:index,:show]
  resources :products, only: [:index, :show] do
    collection do
      get 'top_products', to: 'products#top_products'
      get 'featured_products', to: 'products#random_categories_with_products'
    end
  end
  resources :addresses, only: [:index, :show, :create, :update, :destroy]
  resources :categories, only: [:index]
  
  #Order and Payment Routes
  resources :orders, only: [:index, :show] do
    collection do
      post 'checkout', to: 'orders#checkout'
      get 'pending_payment', to: 'orders#pending_payment'
    end
  
    # Nested resources for payments within orders
    resources :payments, only: [:create] do
      post 'confirm', on: :collection, to: 'payments#confirm_payment'
    end

    resources :reviews, only: [:create]
  end

  resources :cart, only: [:index], controller: 'order_items' do
    collection do
      post 'add', to: 'order_items#add_to_cart'
      put 'update', to: 'order_items#update_quantity'
      delete 'remove', to: 'order_items#remove_from_cart'
      delete 'clear', to: 'order_items#clear_cart'
    end
  end
  

   # Cart Management Routes 
  #   HTTP Method	Path	Controller#Action
  # GET	/cart	order_items#index
  # POST	/cart/add	order_items#add_to_cart
  # PUT	/cart/update	order_items#update_quantity
  # DELETE	/cart/remove	order_items#remove_from_cart
  # DELETE	/cart/clear	order_items#clear_cart

  # Product Details API

end
