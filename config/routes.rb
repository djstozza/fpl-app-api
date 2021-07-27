# frozen_string_literal: true

Rails.application.routes.draw do
  require 'sidekiq/web'
  require 'sidekiq-scheduler/web'
  mount Sidekiq::Web => '/sidekiq'
  mount ActionCable.server => '/cable'

  devise_for :users, skip: [:registrations, :sessions, :passwords]

  namespace :api do
    devise_scope :user do
      resources :registrations, only: [:create]
      resources :sessions, only: [:create] do
        put :update, on: :collection
        patch :update, on: :collection
      end
      resources :passwords, only: [] do
        put :update, on: :collection
        patch :update, on: :collection
      end
    end

    resource :users, only: [:update]

    resources :players, only: [:index, :show] do
      collection do
        resources :facets, only: [:index], module: :players, as: :players_facets
      end

      scope module: :players do
        resources :history, only: [:index]
        resources :history_past, only: [:index]
      end
    end

    resources :leagues, except: [:edit, :destroy] do
      collection do
        resource :join, only: [:create], module: :leagues, as: :leagues_join
      end

      resource :generate_draft_picks, only: [:create], controller: 'leagues/generate_draft_picks'
      resource :create_draft, only: [:create], controller: 'leagues/create_drafts'
      resources :draft_picks, only: [:index, :update], controller: 'leagues/draft_picks' do
        collection do
          resources :status, only: [:index], module: 'leagues/draft_picks', as: :draft_picks_status
          resources :facets, only: [:index], module: 'leagues/draft_picks', as: :draft_picks_facets
        end
      end
      resources :fpl_teams, only: [:index], controller: 'leagues/fpl_teams'
      resources :mini_draft_picks, only: [:index], module: :leagues do
        collection do
          resources :status, only: [:index], module: :mini_draft_picks, as: :mini_draft_picks_status
          resources :facets, only: [:index], module: :mini_draft_picks, as: :mini_draft_picks_facets
        end
      end
    end
    resources :fpl_teams, only: [:index, :show, :update] do
      resources :fpl_team_lists, module: 'fpl_teams', only: [:index, :show]
    end

    resources :list_positions, only: [:show] do
      resources :waiver_picks, only: [:create], module: :list_positions
      resources :trades, only: [:create], module: :list_positions
      resources :tradeable_list_positions, only: [:index], module: :list_positions
      resources :tradeable_list_position_facets, only: [:index], module: :list_positions
    end

    resources :fpl_team_lists, only: [:index, :show, :update] do
      resources :list_positions, only: [:index], module: 'fpl_team_lists' do
        resources :mini_draft_picks, only: [:create], module: :list_positions
      end
      resources :waiver_picks, only: [:index, :destroy], module: 'fpl_team_lists' do
        resource :change_order, only: [:create], module: :waiver_picks
      end

      resources :trades, only: [:index], module: :fpl_team_lists
      resources :inter_team_trade_groups, only: [:index, :create], module: :fpl_team_lists do
        resource :submit, only: [:create], module: :inter_team_trade_groups
        resource :add_trade, only: [:create], module: :inter_team_trade_groups
        resource :approve, only: [:create], module: :inter_team_trade_groups
        resource :decline, only: [:create], module: :inter_team_trade_groups
        resource :cancel, only: [:create], module: :inter_team_trade_groups
      end

      resources :inter_team_trades, only: [:destroy], module: :fpl_team_lists
    end

    resources :rounds, only: [:index, :show]
    resources :positions, only: [:index]
    resources :teams, only: [:index, :show] do
      scope module: :teams do
        resources :fixtures, only: [:index]
      end
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
