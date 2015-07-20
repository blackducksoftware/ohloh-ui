Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  root to: 'home#index'

  use_doorkeeper do
    skip_controllers :applications, :authorized_applications
  end

  resources :sessions, only: [:new, :create] do
    collection do
      delete :destroy
    end
  end

  resources :stack_entries, only: :new

  resources :password_resets, only: [:new, :create] do
    collection do
      get :confirm
      patch :reset
    end
  end
  resources :activation_resends, only: [:new, :create]

  resources :api_keys, only: :index
  resources :domain_blacklists, except: :show
  resources :reviews, only: :destroy do
    resources :helpfuls, only: :create
  end
  resources :kudos, only: [:new, :create, :destroy]

  resources :people, only: [:index] do
    collection { get :rankings }
  end
  resources :edits, only: [:update]

  resources :licenses do
    resources :edits, only: [:index]
  end

  resources :tags, only: [:index, :show]

  resources :accounts do
    resources :api_keys, constraints: { format: :html }
    resources :projects, only: [:index]
    resources :positions, only: [:index] do
      member do
        get :commits_compound_spark
      end
      collection do
        get :one_click_create
      end
    end
    resources :stacks, only: [:index]
    resources :account_widgets, path: :widgets, as: :widgets, only: :index do
      collection do
        get :account_detailed
        get :account_tiny
        get :account_rank
      end
    end
    resources :kudos, only: [:index, :show] do
      collection do
        get :sent
      end
    end
    resources :edits, only: [:index]
    resources :posts, only: [:index]
    resources :reviews, only: [:index]
    resources :positions
    resources :position_factories, only: :create

    member do
      get :confirm_delete
      get :disabled
      get :settings
      get 'password/edit', to: 'passwords#edit'
      patch 'password/edit', to: 'passwords#update'
      get :edit_privacy, to: 'privacy#edit', as: :edit_account_privacy
      patch :edit_privacy, to: 'privacy#update', as: :account_privacy
    end

    collection do
      get :me
      get :unsubscribe_emails
    end

    resources :charts, only: [], module: :accounts do
      collection do
        get :commits_by_project
        get :commits_by_language
        get :commits_by_individual_project
      end
    end

    resources :languages, only: :index, module: :accounts

    resources :accesses, only: [], module: :accounts do
      collection do
        post :make_spammer
        get :activate
      end
    end

    get 'doorkeeper/oauth_applications/:id/revoke_access' =>
      'doorkeeper/oauth_applications#revoke_access', as: :revoke_oauth_access
  end

  resources :deleted_accounts, only: [:edit, :update]

  resources :check_availabilities, only: [] do
    collection do
      get :account
      get :project
      get :organization
      get :license
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
      get :licenses
      get :contributions
      get :tags
    end
  end

  resources :forums do
    resources :topics, shallow: true
  end

  resources :topics, except: [:index, :new, :create] do
    resources :posts, except: [:new]
  end

  resources :posts, only: :index, as: 'all_posts'
  get 'markdown_syntax', to: 'abouts#markdown_syntax'
  get 'maintenance', to: 'abouts#maintenance'
  get 'tools', to: 'abouts#tools'

  get 'p/compare', to: 'compares#projects', as: :compare_projects
  get 'p/graph', to: 'compares#projects_graph', as: :compare_graph_projects
  get 'projects/:id/stacks', to: 'stacks#project_stacks', constraints: { format: /xml/ }
  get 'p/:id/stacks', to: 'stacks#project_stacks', as: :project_stacks, constraints: { format: /xml/ }
  get 'p/:id/stacks', to: redirect('/p/%{id}/users'), constraints: { format: /html/ }
  get 'projects', to: 'projects#index', as: :project_xml_api, constraints: { format: /xml/ }

  resources :duplicates, only: [:index, :show] do
    member do
      post 'resolve/:keep_id', to: 'duplicates#resolve'
    end
  end

  resources :projects, path: :p, except: [:destroy] do
    member do
      get :users
      get :map
      get :settings
      get :estimated_cost
      get :similar_by_tags
      get :similar
      get 'permissions'  => 'permissions#show',   as: :permissions
      put 'permissions'  => 'permissions#update', as: :update_permissions
      post 'rate'        => 'ratings#rate',       as: :rate
      delete 'unrate'    => 'ratings#unrate',     as: :unrate
    end
    collection do
      post :check_forge
    end
    resources :contributions, path: :contributors, as: :contributors, only: [:index, :show] do
      resources :commits
      collection do
        get :near
        get :summary
      end
      member do
        get :commits_compound_spark
        get :commits_spark
      end
    end
    resources :rss_subscriptions
    resources :licenses, controller: :project_licenses, only: [:index, :new, :create, :destroy]
    resources :tags, controller: :project_tags, only: [:index, :create, :destroy] do
      collection do
        get :related
        get :status
      end
    end
    resources :duplicates, except: [:show, :index]
    resource :logos, only: [:new, :create, :destroy]
    resources :links, except: :show
    resources :managers, only: [:index, :new, :create, :edit, :update] do
      member do
        post :approve
        post :reject
      end
    end
    resources :manages, only: [:new]
    resources :edits, only: [:index]
    resources :enlistments
    resources :factoids, only: [:index]
    resources :rss_articles, only: :index
    resources :project_widgets, path: :widgets, as: :widgets, only: :index do
      collection do
        get :project_factoids
        get :project_factoids_stats
        get :project_basic_stats
        get :project_users
        get :project_users_logo
        get :project_search_code
        get :project_browse_code
        get :project_search_all_code
        get :project_languages
        get :project_partner_badge
        get :project_thin_badge
        get :project_cocomo
      end
    end
    resources :ratings
    resources :reviews, except: :show do
      collection { get :summary }
      resources :helpfuls, only: :create
    end
    resources :analyses, only: [:index, :show] do
      member do
        get :languages_summary
        get :languages
        get :licenses
        get :top_commit_volume_chart
        get :commits_history
        get :committer_history
        get :contributor_summary
        get :language_history
        get :code_history
        get :lines_of_code
        get :commits_spark
      end

      resources :activity_facts, only: :index
      resources :size_facts, only: :index
    end
    resources :commits, only: [:index, :show] do
      collection { get :summary }
      member do
        get :statistics
        get :events
        get :event_details
      end
    end
    resources :contributors do
      member do
        get :event_details
        get :events
      end
    end
    resources :stacks, only: [] do
      collection { get :near }
    end
    resources :aliases, only: [:index, :new, :create] do
      collection { get :preferred_names }
      member do
        post :undo
        post :redo
      end
    end
  end

  resources :organizations, path: :orgs do
    member do
      get :settings
      get :projects
      get :outside_projects
      get :outside_committers
      get :print_infographic
      get :affiliated_committers
      get :list_managers
      get :claim_projects_list
      get :claim_project
      put :remove_project
      match :new_manager, via: [:get, :post]
      get :manage_projects
    end

    collection do
      get :resolve_url_name
    end

    resources :edits, only: [:index]
    resource :logos, only: [:new, :create, :destroy]
    resources :managers, only: [:index, :new, :create, :edit, :update] do
      member do
        post :approve
        post :reject
      end
    end
    resources :organization_widgets, path: :widgets, as: :widgets, only: :index do
      collection do
        get :affiliated_committers_activity
        get :open_source_activity
        get :portfolio_projects_activity
      end
    end
  end

  resources :stacks, only: [:show, :create, :update, :destroy] do
    member do
      get :similar
      get :similar_stacks
      get :builder
      get :reset
    end
    resources :stack_entries, only: [:show, :create, :update, :destroy]
    resources :stack_ignores, only: [:create] do
      collection do
        delete :delete_all
      end
    end
    resources :stack_widgets, path: :widgets, as: :widgets, only: :index do
      collection do
        get :stack_normal
      end
    end
  end

  resources :languages, only: [:show, :index] do
    collection do
      get :compare
      get :chart
    end
  end

  resources :contributors, controller: 'contributions' do
    resources :invites, only: [:new, :create]
  end

  resources :explores, only: :index, path: :explore, controller: :explore do
    collection do
      get :orgs
      get :projects
      get :demographic_chart
      get :orgs_by_thirty_day_commit_volume
    end
  end

  get 'maintenance' => 'home#maintenance'

  get 'repositories/compare' => 'compare_repositories#index', as: :compare_repositories
  get 'repositories/chart' => 'compare_repositories#chart', as: :compare_repositories_chart

  get 'server_info' => 'home#server_info'

  resources :committers, only: [:index, :show] do
    member do
      post :claim
      post :save_claim
    end
  end

  resources :session_projects, only: [:index, :create, :destroy]

  get 'sitemap_index.xml', controller: 'sitemap', action: 'index', format: 'xml'
  get 'sitemaps/:ctrl/:page.xml', controller: 'sitemap', action: 'show', format: 'xml'

  # the unmatched_route must be last as it matches everything
  match '*unmatched_route', to: 'application#raise_not_found!', via: :all
end
