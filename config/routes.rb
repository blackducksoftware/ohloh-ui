Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  root 'home#index'
  resources :sessions, only: [:new, :create] do
    collection do
      delete :destroy
    end
  end

  resources :password_reset, only: [:new, :create] do
    collection do
      get :confirm
      post :reset
    end
  end
  resources :activation_resends, only: [:new, :create]

  resources :api_keys, only: :index
  resources :domain_blacklists, except: :show

  resources :accounts do
    resources :api_keys, constraints: { format: :html }, except: :show
    resources :projects, only: [:index]
    resources :positions, only: [:index]
    member do
      get :settings
      get :languages
      get 'edit_privacy'   => 'privacy#edit',   as: :edit_account_privacy
      put 'update_privacy' => 'privacy#update', as: :account_privacy
    end
  end

  resources :forums do
    resources :topics do
      resources :posts, except: :show
    end
  end

  resources :projects, path: :p, only: [:show] do
    member do
      get :settings
      get 'permissions'  => 'permissions#show',   as: :permissions
      put 'permissions'  => 'permissions#update', as: :update_permissions
      post 'rate/:score' => 'ratings#rate',       as: :rate
      post 'unrate'      => 'ratings#unrate',     as: :unrate
    end
    resource :logos, only: [:new, :create, :destroy]
    resources :managers, only: [:index, :new, :create, :edit, :update] do
      member do
        post :approve
        post :reject
      end
    end
    resources :reviews do
      resources :helpfuls, only: :create
    end
  end

  resources :organizations, path: :orgs, only: [:show] do
    member do
      get :settings
    end
    resource :logos, only: [:new, :create, :destroy]
    resources :managers, only: [:index, :new, :create, :edit, :update] do
      member do
        post :approve
        post :reject
      end
    end
  end

  resources :projects
  resources :stacks, except: [:new, :edit]
  resources :language, only: [:show]

  # The priority is based upon order of creation: first created -> highest
  # priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically)
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
