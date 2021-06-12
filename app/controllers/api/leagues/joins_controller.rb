module Api::Leagues
  class JoinsController < Api::LeaguesController
    # POST /api/leagues/join
    def create
      service = Leagues::Join.call(league_params, current_user, league: league)

      respond_with service.errors.any? ? service : LeagueSerializer.map(leagues, current_user: current_user)
    end

    private

    def league
      League.find_by('LOWER(name) = :name', name: league_params[:name].downcase.strip)
    end

    def league_params
      params.require(:league).permit(:name, :fpl_team_name, :code)
    end
  end
end
