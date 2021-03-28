class Api::TeamsController < ApplicationController
  load_resource :team, only: [:show]

  # GET /api/teams
  def index
    respond_with TeamSerializer.map(teams)
  end

  # GET /api/teams/1
  def show
    query = TeamDetailQuery.new(team)
    respond_with query if stale?(query)
  end

  private

  def teams
    Team.order(sort_params.to_h)
  end

  # Use callbacks to share common setup or constraints between actions.
  def team
    @team ||= Team.find(params[:id])
  end

  def sort_params
    params.require(:sort).permit(
      :position,
      :name,
      :short_name,
      :played,
      :wins,
      :losses,
      :draws,
      :goals_for,
      :goals_against,
      :goal_difference,
      :clean_sheets,
      :points
    )
  end
end
