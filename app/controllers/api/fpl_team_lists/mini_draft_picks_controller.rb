module Api::FplTeamLists
  class MiniDraftPicksController < Api::FplTeamListsController
    load_resource :fpl_team_list

    def create
      service = ::MiniDraftPicks::Pass.call(mini_draft_pick_params.to_h, fpl_team_list, current_user)

      respond_with service.errors.any? ? service : league.mini_draft_status_hash(fpl_team_list.fpl_team, current_user)
    end

    private

    def mini_draft_pick_params
      params.require(:mini_draft_pick).permit(:passed)
    end

    def league
      @league ||= fpl_team_list.league.decorate
    end
  end
end
