class InterTeamTradeGroups::Create < InterTeamTradeGroups::BaseService
  validate :user_can_trade
  validate :valid_out_player
  validate :valid_in_player
  validate :same_positions
  validate :same_league
  validate :same_round
  validate :valid_team_quota_out_fpl_team
  validate :valid_team_quota_in_fpl_team

  def initialize(data, out_fpl_team_list, in_fpl_team_list, user)
    @out_player_id = data[:out_player_id]
    @in_player_id = data[:in_player_id]
    @out_fpl_team_list = out_fpl_team_list
    @out_fpl_team = out_fpl_team_list.fpl_team
    @in_fpl_team_list = in_fpl_team_list
    @in_fpl_team = in_fpl_team_list.fpl_team
    @inter_team_trade_group = InterTeamTradeGroup.new
    @inter_team_trade = InterTeamTrade.new
    @user = user
  end

  def call
    return unless valid?

    update_inter_team_trade_group
    update_inter_team_trade
  end

  private

  def update_inter_team_trade_group
    inter_team_trade_group.update(
      out_fpl_team_list: out_fpl_team_list,
      in_fpl_team_list: in_fpl_team_list,
    )

    errors.merge!(inter_team_trade_group.errors)
  end

  def update_inter_team_trade
    inter_team_trade.update(
      out_player: out_player,
      in_player: in_player,
      inter_team_trade_group: inter_team_trade_group
    )

    errors.merge!(inter_team_trade.errors)
  end
end
