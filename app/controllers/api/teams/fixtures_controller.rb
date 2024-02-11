class Api::Teams::FixturesController < ApplicationController
  load_resource :team, only: [:show]

  before_action :check_cache

  # GET /api/teams/id/fixtures
  def show
    respond_with SqlQuery.results(
      'teams/fixtures',
      team_id: team.id,
      sort: SqlQuery.lit(sort_params.to_h.map { |k, v| "#{k} #{v}" }.join(', '))
    )
  end

  private

  def check_cache
    result = SqlQuery.run('teams/fixtures_cache', team_id: team.id).first
    stale?(etag: result.values, last_modified: result[:last_modified])
  end

  # Use callbacks to share common setup or constraints between actions.
  def team
    @team ||= Team.find(params[:team_id])
  end

  def sort_params
    params.fetch(:sort, {}).permit(
      :kickoff_time,
      :leg,
      :result,
      :strength,
      'opposition_team.short_name',
      'rounds.deadline_time',
    )
  end
end
