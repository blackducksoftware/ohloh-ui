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
  resources :reviews, only: :destroy do
    resources :helpfuls, only: :create
  end
  resources :kudos, only: [:new, :create, :destroy]

  resources :people, only: [:index]
  resources :edits, only: [:update]

  resources :licenses do
    resources :edits, only: [:index]
  end

  resources :accounts do
    resources :api_keys, constraints: { format: :html }, except: :show
    resources :projects, only: [:index]
    resources :positions, only: [:index]
    resources :stacks, only: [:index]
    resources :widgets, only: [:index]
    resources :kudos, only: [:index] do
      collection do
        get :sent
      end
    end
    resources :edits, only: [:index]
    resources :posts, only: [:index]
    resources :reviews, only: [:index]

    member do
      get :confirm_delete
      get :disabled
      get :settings
      get 'edit_privacy'   => 'privacy#edit',   as: :edit_account_privacy
      put 'update_privacy' => 'privacy#update', as: :account_privacy
    end

    collection do
      get :unsubscribe_emails
    end

    resources :charts, only: [], module: :accounts do
      collection do
        get :commits_by_project
        get :commits_by_language
      end
    end

    resources :languages, only: :index, module: :accounts

    resources :accesses, only: [], module: :accounts do
      collection do
        post :make_spammer
        get :activate
      end
    end
  end

  resources :deleted_accounts, only: [:edit, :update]

  resources :check_availabilities, only: [] do
    collection do
      get :account
    end
  end

  resources :searches, only: [] do
    collection do
      get :account
    end
  end

  resources :autocompletes, only: [] do
    collection do
      get :account
      get :project
    end
  end

  resources :forums do
    resources :topics, shallow: true
  end

  resources :topics, except: [:index, :new, :create] do
    resources :posts, except: [:new]
  end
  get 'move_topic/:id', to: 'topics#move_topic', as: :move_topic

  resources :posts, only: :index, as: 'all_posts'
  get 'markdown_syntax', to: 'abouts#markdown_syntax'
  get 'message', to: 'about#message'
  get 'maintenance', to: 'about#maintenance'

  resources :projects, path: :p, only: [:index, :show, :edit] do
    member do
      get :users
      get :map
      get :settings
      get :estimated_cost
      get 'permissions'  => 'permissions#show',   as: :permissions
      put 'permissions'  => 'permissions#update', as: :update_permissions
      post 'rate'        => 'ratings#rate',       as: :rate
      delete 'unrate'      => 'ratings#unrate',     as: :unrate
    end
    collection do
      get :compare
    end
    resource :logos, only: [:new, :create, :destroy]
    resources :links, except: :show
    resources :managers, only: [:index, :new, :create, :edit, :update] do
      member do
        post :approve
        post :reject
      end
    end
    resources :edits, only: [:index]
    resources :rss_articles, only: :index
    resources :widgets, only: :index
    resources :similar_projects, only: :index
    resources :ratings
    resources :reviews, except: :show do
      collection { get :summary }
      resources :helpfuls, only: :create
    end
    resources :analyses, only: :index do
      resources :activity_facts, only: :index
      member do
        get :languages_summary
      end
    end
    resources :commits, only: :index do
      collection { get :summary }
    end
    resources :contributors, only: [:index, :show] do
      collection { get :summary }
    end
  end

  resources :organizations, path: :orgs, only: [:index, :show] do
    member do
      get :settings
      get :projects
      get :outside_projects
      get :outside_committers
      get :print_infographic
      get :affiliated_committers
    end
    resources :edits, only: [:index]
    resource :logos, only: [:new, :create, :destroy]
    resources :managers, only: [:index, :new, :create, :edit, :update] do
      member do
        post :approve
        post :reject
      end
    end
    resources :widgets
  end

  resources :stacks, only: [:show, :create, :update, :destroy] do
    member do
      get :similar
      get :builder
    end
    resources :stack_entries, only: [:create, :destroy]
    resources :stack_ignores, only: [:create] do
      collection do
        delete :delete_all
      end
    end
    resources :widgets, only: [:index]
  end

  resources :languages, only: [:show, :index] do
    collection { get :compare }
  end

  resources :people do
    collection { get :rankings }
  end

  resource :compare_repositories

  resources :contributors, controller: 'contributions' do
    resources :invites, only: [:new, :create]
  end

  get 'explore/orgs' => 'explore#orgs'
  get 'explore/orgs_by_thirty_day_commit_volume' => 'explore#orgs_by_thirty_day_commit_volume'

  get 'message' => 'home#message'
  get 'maintenance' => 'home#maintenance'

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
