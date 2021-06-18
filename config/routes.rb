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
          resources :facets, only: [:index], module: 'leagues/draft_picks', as: :draft_picks_facets
        end
      end
      resources :fpl_teams, only: [:index], controller: 'leagues/fpl_teams'
    end
    resources :fpl_teams, only: [:index, :show, :update]

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
