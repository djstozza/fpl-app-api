module Api::FplTeamLists
  class ListPositionsController < Api::FplTeamListsController
    load_resource :fpl_team_list

    def index
      respond_with list_positions_query if stale?(list_positions_query)
    end
  end
end
