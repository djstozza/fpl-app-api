class Api::LeaguesController < ApplicationController
  before_action :authenticate_user!
  before_action :check_user_authorisation, only: [:update]

  load_resource :league, only: [:show, :update]

  # GET /api/leagues
  def index
    leagues = LeagueSerializer.map(current_user.leagues.order(:name))

    respond_with(leagues)
  end

  # GET /api/leagues/1
  def show
    respond_with(serialized_league(league))
  end

  # POST /api/leagues
  def create
    league = League.create!({ **league_params, owner: current_user })

    respond_with(serialized_league(league))
  end

  # PUT /api/leagues/1
  def update
    league.update!(league_params)

    respond_with(serialized_league(league))
  end

  private

  def league
    @league ||= League.find(params[:id])
  end

  def serialized_league(league)
    LeagueSerializer.new(league, current_user: current_user)
  end

  def league_params
    params.require(:league).permit(:name, :code)
  end

  def check_user_authorisation
    return if league.owner == current_user

    head :unauthorized
  end
end
