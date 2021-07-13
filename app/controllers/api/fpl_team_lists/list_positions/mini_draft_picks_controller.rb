module Api::FplTeamLists
  class ListPositions::MiniDraftPicksController < ListPositionsController
    load_resource :fpl_team_list
    load_resource :list_position

    def create
      service = ::MiniDraftPicks::Process.call(mini_draft_pick_params.to_h, list_position, current_user)

      respond_with service.errors.any? ? service : league.mini_draft_status_hash(fpl_team_list.fpl_team, current_user)
    end

    private

    def mini_draft_pick_params
      params.require(:mini_draft_pick).permit(:in_player_id, :passed)
    end

    def league
      @league ||= fpl_team_list.league.decorate
    end
  end
end
