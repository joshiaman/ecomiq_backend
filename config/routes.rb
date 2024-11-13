Rails.application.routes.draw do
  
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  post 'signup', to: 'authentication#signup'
  post 'login', to: 'authentication#login'

  # User Details routes
  resources :users, only: [:index,:show]
  resources :products, only: [:index, :show]
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

  # Cart Management Routes 
  #   HTTP Method	Path	Controller#Action
  # GET	/cart	order_items#index
  # POST	/cart/add	order_items#add_to_cart
  # PUT	/cart/update	order_items#update_quantity
  # DELETE	/cart/remove	order_items#remove_from_cart
  # DELETE	/cart/clear	order_items#clear_cart
  resources :cart, only: [:index], controller: 'order_items' do
    collection do
      post 'add', to: 'order_items#add_to_cart'
      put 'update', to: 'order_items#update_quantity'
      delete 'remove', to: 'order_items#remove_from_cart'
      delete 'clear', to: 'order_items#clear_cart'
    end
  end
  


  # Product Details API

end
