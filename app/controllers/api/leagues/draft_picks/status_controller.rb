module Api::Leagues
  class DraftPicks::StatusController < Api::Leagues::DraftPicksController
    load_resource :league

    # GET /api/leagues/1/draft_picks/status
    def index
      respond_with SqlQuery.load(
        'leagues/draft_picks/status',
        league_id: league.id,
        can_draft: league.can_go_to_draft?,
        current_user_id: current_user.id,
      ).result
    end
  end
end
