class InterTeamTradeGroups::Submit < InterTeamTradeGroups::BaseService
  validate :user_can_trade
  validate :is_pending
  validate :no_duplicate_trades
  validate :all_out_players_tradeable
  validate :alL_in_players_tradeable
  validate :valid_team_quota_out_fpl_team
  validate :valid_team_quota_in_fpl_team

  def initialize(inter_team_trade_group, user)
    @inter_team_trade_group = inter_team_trade_group
    @out_fpl_team_list = inter_team_trade_group.out_fpl_team_list
    @in_fpl_team_list = inter_team_trade_group.in_fpl_team_list
    @in_fpl_team = inter_team_trade_group.in_fpl_team
    @user = user
  end

  def call
    return unless valid?

    inter_team_trade_group.update(status: 'submitted')
    errors.merge!(inter_team_trade_group.errors)
  end
end
