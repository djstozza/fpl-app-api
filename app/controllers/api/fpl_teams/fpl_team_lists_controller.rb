module Api::FplTeams
  class FplTeamListsController < Api::FplTeamsController
    load_resource :fpl_team

    # GET /api/fpl_teams/1/fpl_team_lists
    def index
      respond_with query
    end

    private

    def query
      SqlQuery.results(
        'fpl_team_lists/players',
        fpl_team_id: fpl_team.id,
        round_id: fpl_team_list_params[:round_id],
      )
    end

    def fpl_team_list_params
      params.require(:fpl_team_list).permit(:round_id)
    end
  end
end
