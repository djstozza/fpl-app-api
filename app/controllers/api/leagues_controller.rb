class Api::LeaguesController < ApplicationController
  before_action :authenticate_user!

  load_resource :league, only: [:show, :update]

  # GET /api/leagues
  def index
    respond_with(LeagueSerializer.map(leagues, current_user: current_user))
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

  def leagues
    League
      .includes(:owner)
      .joins(:fpl_teams)
      .where('fpl_teams.owner_id = ?', current_user.id)
      .order(sort_params.to_h)
  end

  def serialized_league(league)
    LeagueSerializer.new(league, current_user: current_user, fpl_teams: true)
  end

  def league_params
    params.require(:league).permit(:name, :code, :fpl_team_name)
  end

  def sort_params
    params.fetch(:sort, {}).permit(
      :name,
      :status,
    )
  end
end
