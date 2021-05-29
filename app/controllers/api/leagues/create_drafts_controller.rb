module Api::Leagues
  class CreateDraftsController < Api::LeaguesController
    load_resource :league

    # POST /api/leagues/league_id/create_drafts
    def create
      service = Leagues::CreateDraft.call(league, current_user)

      respond_with service.errors.any? ? service : serialized_league(service.league.reload)
    end
  end
end
