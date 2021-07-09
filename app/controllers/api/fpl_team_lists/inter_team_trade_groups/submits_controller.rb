module Api::FplTeamLists
  class InterTeamTradeGroups::SubmitsController < InterTeamTradeGroupsController
    load_resource :fpl_team_list
    load_resource :inter_team_trade_group

    def create
      service = ::InterTeamTradeGroups::Submit.call(inter_team_trade_group, current_user)

      respond_with service.errors.any? ? service : inter_team_trade_groups_query.result
    end
  end
end
