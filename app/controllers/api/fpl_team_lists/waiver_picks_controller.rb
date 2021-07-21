module Api::FplTeamLists
  class WaiverPicksController < Api::FplTeamListsController
    load_resource :fpl_team_list

    def index
      respond_with waiver_picks_query if stale?(waiver_picks_query)
    end

    def destroy
      service = ::WaiverPicks::Destroy.call(waiver_pick, current_user)

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
  end
end
