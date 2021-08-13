require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_USERNAME"])) &
      ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_PASSWORD"]))
  end
  mount Sidekiq::Web => '/sidekiq'
  mount ActionCable.server => '/cable'

  devise_for :users, skip: %i[registrations sessions passwords]

  namespace :api do
    devise_scope :user do
      resources :registrations, only: %i[create]
      resources :sessions, only: %i[create] do
        put :update, on: :collection
        patch :update, on: :collection
      end
      resources :passwords, only: [] do
        put :update, on: :collection
        patch :update, on: :collection
      end
    end

    resource :users, only: %i[update]

    resources :players, only: %i[index show] do
      collection do
        resources :facets, only: %i[index], module: :players, as: :players_facets
      end

      scope module: :players do
        resources :history, only: %i[index]
        resources :history_past, only: %i[index]
      end
    end

    resources :leagues, except: %i[edit destroy] do
      collection do
        resource :join, only: %i[create], module: :leagues, as: :leagues_join
      end

      resource :generate_draft_picks, only: %i[create], controller: 'leagues/generate_draft_picks'
      resource :create_draft, only: %i[create], controller: 'leagues/create_drafts'
      resources :draft_picks, only: %i[index update], controller: 'leagues/draft_picks' do
        collection do
          resources :status, only: %i[index], module: 'leagues/draft_picks', as: :draft_picks_status
          resources :facets, only: %i[index], module: 'leagues/draft_picks', as: :draft_picks_facets
        end
      end
      resources :fpl_teams, only: %i[index], controller: 'leagues/fpl_teams'
      resources :mini_draft_picks, only: %i[index], module: :leagues do
        collection do
          resources :status, only: %i[index], module: :mini_draft_picks, as: :mini_draft_picks_status
          resources :facets, only: %i[index], module: :mini_draft_picks, as: :mini_draft_picks_facets
        end
      end
    end
    resources :fpl_teams, only: %i[index show update] do
      resources :fpl_team_lists, module: 'fpl_teams', only: %i[index show]
    end

    resources :list_positions, only: %i[show] do
      resources :waiver_picks, only: %i[create], module: :list_positions
      resources :trades, only: %i[create], module: :list_positions
      resources :tradeable_list_positions, only: %i[index], module: :list_positions
      resources :tradeable_list_position_facets, only: %i[index], module: :list_positions
    end

    resources :fpl_team_lists, only: %i[index show update] do
      resources :list_positions, only: %i[index], module: 'fpl_team_lists' do
        resources :mini_draft_picks, only: %i[create], module: :list_positions
      end
      resources :waiver_picks, only: %i[index destroy], module: 'fpl_team_lists' do
        resource :change_order, only: %i[create], module: :waiver_picks
      end

      resources :trades, only: %i[index], module: :fpl_team_lists
      resources :inter_team_trade_groups, only: %i[index show create], module: :fpl_team_lists do
        resource :submit, only: %i[create], module: :inter_team_trade_groups
        resource :add_trade, only: %i[create], module: :inter_team_trade_groups
        resource :approve, only: %i[create], module: :inter_team_trade_groups
        resource :decline, only: %i[create], module: :inter_team_trade_groups
        resource :cancel, only: %i[create], module: :inter_team_trade_groups
      end

      resources :inter_team_trades, only: %i[destroy], module: :fpl_team_lists
    end

    resources :rounds, only: %i[index show]
    resources :positions, only: %i[index]
    resources :teams, only: %i[index show] do
      scope module: :teams do
        resources :fixtures, only: %i[index]
      end
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
