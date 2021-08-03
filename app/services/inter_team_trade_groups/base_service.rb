class InterTeamTradeGroups::BaseService < ApplicationService
  attr_reader :out_fpl_team_list,
              :out_fpl_team,
              :out_player_id,
              :out_player,
              :in_fpl_team_list,
              :in_fpl_team,
              :in_player_id,
              :in_player,
              :inter_team_trade_group,
              :inter_team_trade,
              :user

  private

  def user_can_trade
    return errors.add(:base, 'You are not authorised to perform this action') if out_fpl_team_list.owner != user

    trade_window_open
  end

  def user_can_approve
    return errors.add(:base, 'You are not authorised to perform this action') if in_fpl_team_list.owner != user

    trade_window_open
  end

  def trade_window_open
    return errors.add(:base, 'This trade is not from the current round') unless out_fpl_team_list.current?
    return unless Time.current > out_fpl_team_list.deadline_time

    errors.add(:base, 'The trade window is now closed')
  end

  def same_league
    return if in_fpl_team_list.league == out_fpl_team_list.league

    errors.add(:base, "#{in_fpl_team.name} is not part of #{out_fpl_team.league.name}")
  end

  def same_round
    return if in_fpl_team_list.round == out_fpl_team_list.round

    errors.add(:base, 'The team list you are attempting to trade with is invalid')
  end

  def valid_out_player
    @out_player = out_fpl_team_list.players.find_by(id: out_player_id)
    return if @out_player.present?

    errors.add(:base, 'The player you have selected to trade out is not part of your team')
  end

  def valid_in_player
    @in_player = in_fpl_team_list.players.find_by(id: in_player_id)
    return if @in_player.present?

    errors.add(:base, "The player you have selected to trade in is not part of #{in_fpl_team.name}")
  end

  def unique_in_player_in_group
    return unless inter_team_trade_group.in_players.include?(in_player)

    errors.add(:base, "The proposed trade already includes #{in_player.name}")
  end

  def unique_out_player_in_group
    return unless inter_team_trade_group.out_players.include?(out_player)

    errors.add(:base, "The proposed trade already includes #{out_player.name}")
  end

  def valid_team_quota_out_fpl_team
    team = in_teams_for_out_fpl_team_list.detect do |in_team|
      teams_for_out_fpl_team_list.count(in_team) > FplTeam::QUOTAS[:team]
    end

    return unless team

    errors.add(
      :base,
      "You can't have more than #{FplTeam::QUOTAS[:team]} players from the same team (#{team.short_name})",
    )
  end

  def out_teams_for_out_fpl_team_list
    @out_teams_for_out_fpl_team_list ||=
      out_fpl_team_list
      .players
      .where.not(id: [*inter_team_trade_group.out_players, out_player].compact)
      .includes(:team)
      .map(&:team)
  end

  def in_teams_for_out_fpl_team_list
    @in_teams_for_out_fpl_team_list ||= [
      *inter_team_trade_group.in_players.includes(:team).map(&:team),
      in_player&.team,
    ].compact
  end

  def teams_for_out_fpl_team_list
    @teams_for_out_fpl_team_list ||= out_teams_for_out_fpl_team_list + in_teams_for_out_fpl_team_list
  end

  def valid_team_quota_in_fpl_team
    team = out_teams_for_in_fpl_team_list.detect do |out_team|
      teams_for_in_fpl_team_list.count(out_team) > FplTeam::QUOTAS[:team]
    end

    return unless team

    errors.add(
      :base,
      "#{in_fpl_team.name} can't have more than #{FplTeam::QUOTAS[:team]} players from the same team " \
        "(#{team.short_name})",
    )
  end

  def in_teams_for_in_fpl_team_list
    @in_teams_for_in_fpl_team_list ||=
      in_fpl_team_list
      .players
      .where.not(id: [*inter_team_trade_group.in_players, in_player].compact)
      .includes(:team)
      .map(&:team)
  end

  def out_teams_for_in_fpl_team_list
    @out_teams_for_in_fpl_team_list ||= [
      *inter_team_trade_group.out_players.includes(:team).map(&:team),
      out_player&.team,
    ].compact
  end

  def teams_for_in_fpl_team_list
    @teams_for_in_fpl_team_list ||= out_teams_for_in_fpl_team_list + in_teams_for_in_fpl_team_list
  end

  def all_out_players_tradeable
    remainder = inter_team_trade_group.out_players - out_fpl_team_list.players
    return if remainder.empty?

    names = remainder.map(&:name).join(', ')

    errors.add(:base, "Not all the players in this proposed trade are in your team: #{names}")
  end

  def all_in_players_tradeable
    remainder = inter_team_trade_group.in_players - in_fpl_team_list.players
    return if remainder.empty?

    names = remainder.map(&:name).join(', ')

    errors.add(:base, "Not all the players in this proposed trade are in #{in_fpl_team.name}: #{names}")
  end

  def no_duplicate_trades
    return unless duplicates_present

    errors.add(:base, 'You have already proposed this trade')
  end

  def duplicates_present
    InterTeamTradeGroup
      .where.not(status: %w[pending declined])
      .where.not(id: inter_team_trade_group)
      .where(out_fpl_team_list: out_fpl_team_list, in_fpl_team_list: in_fpl_team_list)
      .any? do |trade_group|
        trade_group.in_players == inter_team_trade_group.in_players &&
          trade_group.out_players == inter_team_trade_group.out_players
      end
  end

  def same_positions
    return if out_player.blank? || in_player.blank?
    return if out_player.position == in_player.position

    errors.add(:base, 'Players being traded must have the same positions')
  end

  def pending?
    return if inter_team_trade_group.pending?

    errors.add(:base, 'Changes can no longer be made to the proposed trade')
  end
end
