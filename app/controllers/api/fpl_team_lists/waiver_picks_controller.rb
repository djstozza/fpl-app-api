module Api::FplTeamLists
  class WaiverPicksController < Api::FplTeamListsController
    load_resource :fpl_team_list

    def index
      respond_with waiver_picks_query if stale?(waiver_picks_query)
    end

    def create
      service = ::WaiverPicks::Create.call(waiver_pick_params.to_h, fpl_team_list, current_user)

      respond_with service.errors.any? ? service : waiver_picks_query
    end

    private

    def waiver_pick
      @waiver_pick ||= fpl_team_list.waiver_picks.find(params[:waiver_pick_id] || params[:id])
    end

    def waiver_picks_query
      SqlQuery.results(
        'waiver_picks/by_fpl_team_list',
        fpl_team_list_id: fpl_team_list.id,
        user_id: current_user.id,
      )
    end

    def waiver_pick_params
      params.require(:waiver_pick).permit(:pick_number, :in_player_id, :out_player_id)
    end
  end
end
