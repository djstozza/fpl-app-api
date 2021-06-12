class Api::FplTeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_user_authorisation, only: [:update]

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
    fpl_team.update!(fpl_team_params)

    respond_with(serialized_fpl_team(fpl_team))
  end

  private

  def fpl_team
    @fpl_team ||= FplTeam.find(params[:id])
  end

  def serialized_fpl_team(fpl_team)
    FplTeamSerializer.new(fpl_team, current_user: current_user, league: true)
  end

  def fpl_team_params
    params.require(:fpl_team).permit(:name, :rank, :draft_pick_number, :mini_draft_pick_number)
  end

  def check_user_authorisation
    return if fpl_team.owner == current_user

    head :unauthorized
  end
end
