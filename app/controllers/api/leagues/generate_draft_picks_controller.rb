module Api::Leagues
  class GenerateDraftPicksController < Api::LeaguesController
    load_resource :league

    # POST /api/leagues/league_id/generate_draft_picks
    def create
      service = Leagues::GenerateDraftPick.call(league, current_user)

      respond_with service.errors.any? ? service : FplTeamSerializer.map(fpl_teams.includes(:fpl_team_lists), current_user: current_user)
    end

    private

    def fpl_teams
      @fpl_teams ||= league.fpl_teams.includes(:owner).order(:draft_pick_number)
    end
  end
end
