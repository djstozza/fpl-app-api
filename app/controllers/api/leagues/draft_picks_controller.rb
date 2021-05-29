module Api::Leagues
  class DraftPicksController < Api::LeaguesController
    load_resource :draft_pick, only: [:update]

    # GET api/leagues/league_id/draft_picks
    def index

      respond_with draft_picks_query
    end

    # PUT api/leagues/league_id/draft_picks/id
    def update
      service = Leagues::UpdateDraftPick.call(league_params, league, draft_pick, current_user)

      respond_with service.errors.any? ? service : draft_picks_query
    end

    private

    def league_params
      params.require(:league).permit(:player_id, :mini_draft)
    end

    def draft_pick
      @draft_pick ||= league.draft_picks.find(params[:id])
    end

    def draft_picks_query
      SqlQuery.run('leagues/draft_picks', league_id: league.id, current_user_id: current_user.id)[0]
    end
  end
end
