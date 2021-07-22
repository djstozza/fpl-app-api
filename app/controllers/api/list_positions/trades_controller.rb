module Api::ListPositions
  class TradesController < Api::ListPositionsController
    load_resource :list_position

    def create
      service = ::Trades::Process.call(trade_params.to_h, list_position, current_user)

      respond_with service.errors.any? ? service : query
    end

    private

    def query
      SqlQuery.run(
        'trades/by_fpl_team_list',
        fpl_team_list_id: list_position.fpl_team_list_id,
        user_id: current_user.id,
      )
    end

    def trade_params
      params.require(:trade).permit(:in_player_id)
    end
  end
end
