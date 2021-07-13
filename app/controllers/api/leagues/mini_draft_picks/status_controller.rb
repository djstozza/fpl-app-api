module Api::Leagues
  class MiniDraftPicks::StatusController < Api::Leagues::MiniDraftPicksController
    load_resource :league

    # GET /api/leagues/1/mini_draft_picks/status
    def index
      respond_with league.decorate.mini_draft_status_hash(fpl_team, current_user)
    end

    private

    def fpl_team
      league.fpl_teams.find_by(owner: current_user)
    end
  end
end
