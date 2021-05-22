module Api::Leagues
  class GenerateDraftsController < Api::LeaguesController
    load_resource :league

    # POST /api/leagues/league_id/generate_draft
    def create
      service = Leagues::GenerateDraft.call(league, current_user)

      respond_with service.errors.any? ? service : serialized_league(service.league.reload)
    end
  end
end
