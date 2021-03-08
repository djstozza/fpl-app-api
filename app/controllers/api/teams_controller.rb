class Api::TeamsController < ApplicationController
  load_resource :team, only: [:show]

  # GET /api/teams
  def index
    respond_with TeamSerializer.map(Team.all)
  end

  # GET /api/teams/1
  def show
    query = TeamDetailQuery.new(team)
    respond_with query if stale?(query)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def team
    @team ||= Team.find(params[:id])
  end
end
