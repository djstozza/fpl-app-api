module Api::Leagues
  class JoinsController < Api::LeaguesController
    load_resource :league

    # POST /api/leagues/league_id/join
    def create
      service = Leagues::Join.call(league_params, current_user, league: league)

      respond_with service.errors.any? ? service : serialized_league(service.league.reload)
    end

    private

    def league_params
      params.require(:league).permit(:fpl_team_name, :code)
    end
  end
end
