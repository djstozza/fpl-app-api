module Api::Leagues
  class DraftPicks::FacetsController < Api::Leagues::DraftPicksController
    load_resource :league

    # GET /api/leagues/1/draft_picks/facets
    def index
      respond_with SqlQuery.load('leagues/draft_picks/facets', league_id: league.id).result
    end
  end
end
