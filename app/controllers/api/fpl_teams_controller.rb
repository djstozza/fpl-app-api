class Api::FplTeamsController < ApplicationController
  before_action :authenticate_user!

  load_resource :fpl_team, only: [:show, :update]

  # GET api/fpl_teams
  def index
    respond_with(FplTeamSerializer.map(current_user.fpl_teams, league: true))
  end

  # GET api/fpl_teams/1
  def show
    respond_with(serialized_fpl_team(fpl_team))
  end

  # PUT api/fpl_teams/1
  def update
    service = FplTeams::Update.call(fpl_team_params.to_h, fpl_team, current_user)

    respond_with service.errors.any? ? service : serialized_fpl_team(fpl_team)
  end

  private

  def fpl_team
    @fpl_team ||= FplTeam.find(params[:id] || params[:fpl_team_id])
  end

  def serialized_fpl_team(fpl_team)
    FplTeamSerializer.new(fpl_team, current_user: current_user, league: true)
  end

  def fpl_team_params
    params.require(:fpl_team).permit(:name)
  end
end
