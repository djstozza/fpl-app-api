module Api::Leagues
  class FplTeamsController < Api::LeaguesController
    # GET api/leagues/league_id/fpl_teams
    def index
      respond_with FplTeamSerializer.map(fpl_teams, current_user: current_user)
    end

    private

    def sort_params
      params.fetch(:sort, {}).permit(:name, :draft_pick_number, :mini_draft_pick_number, :rank)
    end

    def fpl_teams
      @fpl_teams ||= league.fpl_teams.includes(:fpl_team_lists, :owner).order(sort_params.to_h)
    end
  end
end
