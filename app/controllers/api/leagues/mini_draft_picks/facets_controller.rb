module Api::Leagues
  class MiniDraftPicks::FacetsController < Api::Leagues::MiniDraftPicksController
    load_resource :league

    # GET /api/leagues/1/draft_picks/facets
    def index
      respond_with query
    end

    private

    def query
      SqlQuery.load(
        'mini_draft_picks/facets',
        league_id: league.id,
        season: MiniDraftPick.seasons[mini_draft_pick_params[:season]],
      ).result
    end

    def mini_draft_pick_params
      params.require(:mini_draft_pick).permit(:season)
    end
  end
end
