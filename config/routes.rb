# frozen_string_literal: true

Rails.application.routes.draw do
  require 'sidekiq/web'
  require 'sidekiq-scheduler/web'
  mount Sidekiq::Web => '/sidekiq'

  namespace :api do
    resources :players, only: [:index, :show] do

      collection do
        resources :facets, only: [:index], module: :players, as: :players_facets
      end
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
