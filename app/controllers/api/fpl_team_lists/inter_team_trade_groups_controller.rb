module Api::FplTeamLists
  class InterTeamTradeGroupsController < Api::FplTeamListsController
    load_resource :fpl_team_list
    load_resource :inter_team_trade_group, only: [:update]

    def index
      respond_with inter_team_trade_groups_query.result if stale?(inter_team_trade_groups_query)
    end

    def create
      service =
        ::InterTeamTradeGroups::Create.call(permitted_params.to_h, fpl_team_list, in_fpl_team_list, current_user)

      respond_with service.errors.any? ? service : inter_team_trade_groups_query.result
    end

    private

    def permitted_params
      params.require(:inter_team_trade_group).permit(
        :in_fpl_team_list_id,
        :out_player_id,
        :in_player_id,
      )
    end

    def in_fpl_team_list
      fpl_team_list
        .league
        .fpl_team_lists
        .find_by(round: fpl_team_list.round, id: permitted_params[:in_fpl_team_list_id])
    end

    def inter_team_trade_group
      @inter_team_trade_group ||= InterTeamTradeGroup.find(params[:inter_team_trade_group_id] || params[:id])
    end
  end
end
