class MiniDraftPicks::Process < ApplicationService
  attr_reader :out_player,
              :in_player_id,
              :in_player,
              :passed,
              :list_position,
              :fpl_team_list,
              :fpl_team,
              :league,
              :user

  validate :user_is_owner
  validate :mini_draft?
  validate :user_can_mini_draft
  validate :next_fpl_team?
  validate :valid_in_player, if: :in_player_id
  validate :maximum_number_of_players_from_team, if: :in_player_id
  validate :same_positions, if: :in_player_id

  def initialize(data, list_position, user)
    @in_player_id = data[:in_player_id]
    @passed = data[:passed]
    @list_position = list_position
    @fpl_team = list_position.fpl_team
    @fpl_team_list = list_position.fpl_team_list
    @out_player = list_position.player
    @league = list_position.league.decorate
    @user = user
  end

  def call
    return unless valid?

    passed ? pass_mini_draft_pick : draft_player

    return if errors.any?

    MiniDraftPicks::BroadcastJob.perform_later(MiniDraftPick.last)
  end

  private

  def draft_player
    current_mini_draft_pick.update(
      out_player: out_player,
      in_player: in_player,
    )

    return errors.megre!(current_mini_draft_pick.errors) if current_mini_draft_pick.errors.any?

    update_list_position_and_fpl_team
  end

  def update_list_position_and_fpl_team
    list_position.update(player: in_player)
    fpl_team.players.delete(out_player)
    fpl_team.players << in_player
  end

  def pass_mini_draft_pick
    current_mini_draft_pick.update(passed: true)
  end

  def next_fpl_team?
    return if league.current_mini_draft_pick.fpl_team == fpl_team

    errors.add(:base, 'It is not your turn to make a mini draft pick')
  end

  def user_can_mini_draft
    return errors.add(:base, 'The round is not current') unless fpl_team_list.current?
    return errors.add(:base, 'The mini draft is not open yet') unless Time.current > Round.mini_draft_deadline
    return unless Time.current > fpl_team_list.waiver_deadline

    errors.add(:base, 'The mini draft is now closed')
  end

  def user_is_owner
    errors.add(:base, 'You are not authorised to perform this action') unless fpl_team.owner == user
  end

  def mini_draft?
    errors.add(:base, 'The mini draft is not active') unless fpl_team_list.mini_draft
  end

  def valid_in_player
    @in_player = Player.find_by(id: in_player_id)
    errors.add(:base, 'The player you have selected to draft in does not exist') if @in_player.blank?

    return unless league.players.find_by(id: in_player_id)

    errors.add(:base, 'The player you have selected to draft in is already part of a team in your league')
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
    fpl_team_list.players.where.not(id: out_player.id).pluck(:team_id) << in_player.team_id
  end

  def same_positions
    return if in_player.blank?
    return if out_player.position == in_player.position

    errors.add(:base, 'Players must have the same positions')
  end

  def current_mini_draft_pick
    league.current_mini_draft_pick
  end
end
