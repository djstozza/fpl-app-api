module Api::FplTeamLists
  class TradesController < Api::FplTeamListsController
    load_resource :fpl_team_list

    def index
      respond_with query if stale?(query)
    end

    private

    def query
      SqlQuery.run(
        'trades/by_fpl_team_list',
        fpl_team_list_id: fpl_team_list.id,
        user_id: current_user.id,
      )
    end
  end
end
