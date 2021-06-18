module Api::Leagues
  class DraftPicksController < Api::LeaguesController
    load_resource :draft_pick, only: [:update]

    # GET api/leagues/league_id/draft_picks
    def index
      respond_with draft_picks_query.result, total: total_query(filtered_draft_picks_query)
    end

    # PUT api/leagues/league_id/draft_picks/id
    def update
      service = Leagues::UpdateDraftPick.call(league_params, league, draft_pick, current_user)

      respond_with service.errors.any? ? service : draft_picks_query.result
    end

    private

    def league_params
      params.require(:league).permit(:player_id, :mini_draft)
    end

    def draft_picks_query
      SqlQuery.load(
        'leagues/draft_picks/index',
        filtered_draft_picks: filtered_draft_picks_query,
        league_id: league.id,
        current_user_id: current_user.id,
        offset: page_params[:offset],
        limit: page_params[:limit],
      )
    end

    def filtered_draft_picks_query
      @filtered_draft_picks_query ||= SqlQuery.load(
        'leagues/draft_picks/filtered',
        team_id: Array(filter_params[:team_id]&.split(',').presence).compact,
        position_id: Array(filter_params[:position_id]&.split(',').presence).compact,
        fpl_team_id: Array(filter_params[:fpl_team_id]&.split(',').presence).compact,
        league_id: league.id,
        mini_draft: filter_params[:mini_draft],
        sort: sort_query,
      )
    end

    def draft_pick
      @draft_pick ||= league.draft_picks.find(params[:id])
    end

    def filter_params
      params.fetch(:filter, {}).permit(
        :position_id,
        :team_id,
        :mini_draft,
        :fpl_team_id,
        :league_id,
      )
    end

    def sort_params
      permitted =
        params.fetch(:sort, {}).permit(
        :pick_number,
        'players.first_name',
        'players.last_name',
        'teams.short_name',
        'positions.singular_name_short',
        'fpl_teams.name',
        'users.username',
      )

      permitted[:pick_number] ||= 'asc'
      permitted
    end

    def page_params
      params.fetch(:page, {}).permit(:limit, :offset)
    end
  end
end
