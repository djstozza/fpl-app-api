class Api::LeaguesController < ApplicationController
  before_action :authenticate_user!

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
    service = Leagues::Create.call(league_params, current_user)

    respond_with service.errors.any? ? service : serialized_league(service.league)
  end

  # PUT /api/leagues/1
  def update
    service = Leagues::Update.call(league_params, current_user, league: league)

    respond_with service.errors.any? ? service : serialized_league(service.league)
  end

  private

  def league
    @league ||= League.find(params[:league_id] || params[:id])
  end

  def serialized_league(league)
    LeagueSerializer.new(league, current_user: current_user, fpl_teams: true)
  end

  def league_params
    params.require(:league).permit(:name, :code, :fpl_team_name)
  end
end
