module Api::ListPositions
  class TradeableListPositionFacetsController < Api::ListPositionsController
    load_resource :list_position

    def index
      respond_with query.result
    end

    private

    def query
      SqlQuery.load(
        'list_positions/tradeable_list_position_facets',
        round_id: list_position.round.id,
        league_id: list_position.league.id,
        position_id: list_position.position.id,
        out_fpl_team_list_id: list_position.fpl_team_list_id,
        in_fpl_team_list_id: filter_params[:in_fpl_team_list_id],
        excluded_player_ids: Array(filter_params[:excluded_player_ids]&.split(',').presence).compact,
      )
    end

    def filter_params
      params.fetch(:filter, {}).permit(
        :in_fpl_team_list_id,
        :excluded_player_ids,
      )
    end
  end
end
