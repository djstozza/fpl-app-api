module Api::ListPositions
  class WaiverPicksController < Api::ListPositionsController
    load_resource :list_position

    def create
      service = ::WaiverPicks::Create.call(waiver_pick_params.to_h, list_position, current_user)

      respond_with service.errors.any? ? service : waiver_picks_query
    end

    private

    def waiver_picks_query
      SqlQuery.results(
        'waiver_picks/by_fpl_team_list',
        fpl_team_list_id: list_position.fpl_team_list_id,
        user_id: current_user.id,
      )
    end

    def waiver_pick_params
      params.require(:waiver_pick).permit(:in_player_id)
    end
  end
end
