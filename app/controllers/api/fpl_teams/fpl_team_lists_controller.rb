module Api::FplTeams
  class FplTeamListsController < Api::FplTeamsController
    load_resource :fpl_team
    load_resource :fpl_team_list, only: [:show]

    # GET /api/fpl_teams/1/fpl_team_lists
    def index
      respond_with FplTeamListSerializer.map(fpl_team.fpl_team_lists.includes(:round).order('rounds.deadline_time'))
    end

    # GET /api/fpl_teams/1/fpl_team_lists/1
    def show
      respond_with query[0] if stale?(query)
    end

    private

    def query
      @query ||= SqlQuery.results(
        'fpl_team_lists/show',
        list_position_details: list_position_details,
        fpl_team_list_id: fpl_team_list.id,
        user_id: current_user.id,
      )
    end

    def list_position_details
      SqlQuery.load(
        'fpl_team_lists/list_position_details',
        fpl_team_list_id: fpl_team_list.id,
      )
    end

    def fpl_team_list
      @fpl_team_list ||= FplTeamList.find(params[:id])
    end

    def fpl_team_list_params
      params.require(:fpl_team_list).permit(:round_id)
    end
  end
end
