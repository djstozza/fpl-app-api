module Api::FplTeamLists
  class WaiverPicks::ChangeOrdersController < WaiverPicksController
    load_resource :fpl_team_list
    load_resource :waiver_pick

    def create
      service = ::WaiverPicks::ChangeOrder.call(waiver_pick_params.to_h, waiver_pick, current_user)

      respond_with service.errors.any? ? service : waiver_picks_query
    end

    private

    def waiver_pick_params
      params.require(:waiver_pick).permit(:new_pick_number)
    end
  end
end
