class InterTeamTradeGroups::Approve < InterTeamTradeGroups::BaseService
  validate :user_can_approve
  validate :submitted?
  validate :all_out_players_tradeable
  validate :all_in_players_tradeable
  validate :valid_team_quota_out_fpl_team
  validate :valid_team_quota_in_fpl_team

  def initialize(inter_team_trade_group, user)
    @inter_team_trade_group = inter_team_trade_group
    @out_fpl_team_list = inter_team_trade_group.out_fpl_team_list
    @out_fpl_team = inter_team_trade_group.out_fpl_team
    @in_fpl_team_list = inter_team_trade_group.in_fpl_team_list
    @in_fpl_team = inter_team_trade_group.in_fpl_team
    @user = user
  end

  def call
    return unless valid?

    inter_team_trade_group.update(status: 'approved')
    errors.merge!(inter_team_trade_group.errors)

    update_list_positions
    transfer_players_in_fpl_team
  end

  private

  def submitted?
    return if inter_team_trade_group.submitted?

    errors.add(:base, 'You can only approve submitted trade proposals')
  end

  def out_players
    @out_players ||= inter_team_trade_group.out_players
  end

  def in_players
    @in_players ||= inter_team_trade_group.in_players
  end

  def update_list_positions
    inter_team_trade_group.inter_team_trades.each do |trade|
      update_out_list_position(trade)
      update_in_list_position(trade)
    end
  end

  def update_out_list_position(trade)
    out_list_position = out_fpl_team_list.list_positions.find_by(player: trade.out_player)
    out_list_position.update(player: trade.in_player)
    errors.merge!(out_list_position.errors)
  end

  def update_in_list_position(trade)
    in_list_position = in_fpl_team_list.list_positions.find_by(player: trade.in_player)
    in_list_position.update(player: trade.out_player)
    errors.merge!(in_list_position.errors)
  end

  def transfer_players_in_fpl_team
    out_fpl_team.players.delete(out_players)
    in_fpl_team.players.delete(in_players)

    out_fpl_team.players << in_players
    in_fpl_team.players << out_players
  end
end
