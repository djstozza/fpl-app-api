module Api::ListPositions
  class TradeableListPositionsController < Api::ListPositionsController
    load_resource :list_position

    def index
      respond_with query if stale?(query)
    end

    private

    def query
      SqlQuery.results(
        'list_positions/tradeable_list_positions',
        out_fpl_team_list_id: list_position.fpl_team_list_id,
        round_id: list_position.round.id,
        league_id: list_position.league.id,
        position_id: list_position.position.id,
        in_fpl_team_list_id: filter_params[:in_fpl_team_list_id],
        excluded_player_ids: Array(filter_params[:excluded_player_ids]&.split(',').presence).compact,
        fpl_team_id: Array(filter_params[:fpl_team_id]&.split(',').presence).compact,
        team_id: Array(filter_params[:team_id]&.split(',').presence).compact,
        sort: sort_query
      )
    end

    def filter_params
      params.fetch(:filter, {}).permit(
        :team_id,
        :fpl_team_id,
        :in_fpl_team_list_id,
        :excluded_player_ids,
      )
    end

    def sort_params
      permitted = params.fetch(:sort, {}).permit(
        :last_name,
        :first_name,
        'teams.short_name',
        'fpl_teams.name',
      )

      permitted['last_name'] ||= 'asc'
      permitted
    end
  end
end
