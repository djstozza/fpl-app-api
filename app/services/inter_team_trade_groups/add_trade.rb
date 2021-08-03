class InterTeamTradeGroups::AddTrade < InterTeamTradeGroups::BaseService
  validate :user_can_trade
  validate :valid_out_player
  validate :valid_in_player
  validate :same_positions
  validate :valid_team_quota_out_fpl_team
  validate :valid_team_quota_in_fpl_team
  validate :unique_in_player_in_group
  validate :unique_out_player_in_group
  validate :pending?

  def initialize(data, inter_team_trade_group, user)
    @inter_team_trade_group = inter_team_trade_group
    @out_player_id = data[:out_player_id]
    @in_player_id = data[:in_player_id]
    @out_fpl_team_list = inter_team_trade_group.out_fpl_team_list
    @out_fpl_team = inter_team_trade_group.out_fpl_team
    @in_fpl_team_list = inter_team_trade_group.in_fpl_team_list
    @in_fpl_team = inter_team_trade_group.in_fpl_team
    @inter_team_trade = InterTeamTrade.new
    @user = user
  end

  def call
    return unless valid?

    inter_team_trade.update(
      inter_team_trade_group: inter_team_trade_group,
      out_player: out_player,
      in_player: in_player,
    )

    errors.merge!(inter_team_trade.errors)
  end
end
