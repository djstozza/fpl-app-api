class Trades::Process < ApplicationService
  attr_reader :fpl_team_list,
              :fpl_team,
              :list_position,
              :out_player,
              :user,
              :in_player_id,
              :in_player,
              :trade

  validate :user_is_owner
  validate :user_can_trade
  validate :valid_in_player
  validate :maximum_number_of_players_from_team
  validate :same_positions

  def initialize(data, list_position, user)
    @list_position = list_position
    @fpl_team_list = list_position.fpl_team_list
    @out_player = list_position.player
    @fpl_team = list_position.fpl_team
    @user = user
    @in_player_id = data[:in_player_id]
  end

  def call
    return unless valid?

    list_position.update(player: in_player)
    fpl_team.players.delete(out_player)
    fpl_team.players << in_player

    create_trade
  end

  private

  def user_can_trade
    return errors.add(:base, 'The team list is not from the current round') unless fpl_team_list.current?
    return errors.add(:base, 'The trade window is not open yet') if Time.current < fpl_team_list.waiver_deadline
    return unless Time.current > fpl_team_list.deadline_time

    errors.add(:base, 'The trade window is now closed')
  end

  def user_is_owner
    errors.add(:base, 'You are not authorised to perform this action') if fpl_team_list.owner != user
  end

  def valid_in_player
    @in_player = Player.find_by(id: in_player_id)
    errors.add(:base, 'The player you have selected to waiver in does not exist') if @in_player.blank?

    return unless fpl_team_list.league.players.find_by(id: in_player_id)

    errors.add(:base, 'The player you have selected to trade in is already part of a team in your league')
  end

  def maximum_number_of_players_from_team
    return if in_player.blank?
    return if team_ids.count(in_player.team_id) <= FplTeam::QUOTAS[:team]

    errors.add(
      :base,
      "You can't have more than #{FplTeam::QUOTAS[:team]} players from the same team (#{in_player.team.short_name})",
    )
  end

  def team_ids
    @team_ids ||= fpl_team_list.players.where.not(id: out_player.id).pluck(:team_id) << in_player.team_id
  end

  def same_positions
    return if in_player.blank?
    return if out_player.position == in_player.position

    errors.add(:base, 'Players must have the same positions')
  end

  def create_trade
    trade = Trade.create(out_player: out_player, in_player: in_player, fpl_team_list: fpl_team_list)
    errors.merge!(trade.errors) if trade.errors.any?
  end
end
