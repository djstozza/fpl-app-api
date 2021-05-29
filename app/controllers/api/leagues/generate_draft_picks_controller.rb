module Api::Leagues
  class GenerateDraftPicksController < Api::LeaguesController
    load_resource :league

    # POST /api/leagues/league_id/generate_draft_picks
    def create
      service = Leagues::GenerateDraftPick.call(league, current_user)

      respond_with service.errors.any? ? service : serialized_league(service.league.reload)
    end
  end
end
