module Api::Leagues
  class JoinsController < Api::LeaguesController
    before_action :authenticate_user!
    load_resource :league

    # GET /api/leagues/league_id/join
    def create
      service = Leagues::Join.call(league_params, current_user, league: league)
      return respond_with service if service.errors.any?

      respond_with(serialized_league(service.league))
    end

    private

    def league_params
      params.require(:league).permit(:fpl_team_name, :code)
    end
  end
end
