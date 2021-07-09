module Api::FplTeamLists
  class InterTeamTradesController < Api::FplTeamListsController
    load_resource :fpl_team_list
    load_resource :inter_team_trade

    def destroy
      service = ::InterTeamTradeGroups::RemoveTrade.call(inter_team_trade, current_user)

      respond_with service.errors.any? ? service : inter_team_trade_groups_query.result
    end

    private

    def inter_team_trade
      @inter_team_trade ||= InterTeamTrade.find(params[:id])
    end
  end
end
