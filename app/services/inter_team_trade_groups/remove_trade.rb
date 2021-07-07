class InterTeamTradeGroups::RemoveTrade < InterTeamTradeGroups::BaseService
  attr_reader :inter_team_trade, :inter_team_trade_group, :out_fpl_team_list, :user

  validate :user_can_trade
  validate :is_pending

  def initialize(inter_team_trade, user)
    @inter_team_trade = inter_team_trade
    @inter_team_trade_group = inter_team_trade.inter_team_trade_group
    @out_fpl_team_list = inter_team_trade.out_fpl_team_list
    @user = user
  end

  def call
    return unless valid?

    inter_team_trade.delete
    errors.merge!(inter_team_trade.errors)

    inter_team_trade_group.delete if inter_team_trade_group.inter_team_trades.blank?
    errors.merge!(inter_team_trade_group.errors)
  end
end
