require 'sidekiq/web'

NaggingMachine::Application.routes.draw do
  mount Sidekiq::Web, at: '/sidekiq'
  devise_for :users, controllers: {registrations: "users/registrations", sessions: "users/sessions"}
  devise_scope :user do
    get 'phone_confirmation' => 'users/registrations'
#    get 'change_phone_number' => 'users/registrations'
  end
  root 'home#index'
  get 'mynags', to: 'nags#index'
  put 'nags/:id/done', to: 'commands#done', as: :done_nag
  put 'stop_nags', to: 'commands#stop'
  put 'restart_nags', to: 'commands#restart'
  post '/h', to: 'commands#hook'
  resources :nags, only: [:index, :create, :update]

  namespace :api do
    resources :nags, only: [:index, :create] do
      member do
        get 'done', to: "nags#done"
      end
    end
    resources :sessions, only: [:create]
    ["sessions", "nags"].each do |options_endpoint|
      match options_endpoint, to: "api#cors_preflight", via: :options
    end
  end
  #  resources :nags, only: [:index]
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
