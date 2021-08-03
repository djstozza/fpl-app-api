# Draft a player or select a place in the mini draft
class Leagues::UpdateDraftPick < Leagues::BaseService
  attr_reader :player_id, :mini_draft, :league, :draft_pick, :player, :user
  delegate :fpl_team, to: :draft_pick

  validate :valid_data
  validate :league_status
  validate :user_is_fpl_team_owner
  validate :draft_pick_is_current
  validate :valid_player, if: :player_id
  validate :valid_player_count, if: :player
  validate :valid_position, if: :player
  validate :player_not_already_picked, if: :player
  validate :maximum_number_of_players_from_team, if: :player
  validate :valid_mini_draft_pick, if: :mini_draft

  def initialize(data, league, draft_pick, user)
    @player_id = data[:player_id]
    @mini_draft = data[:mini_draft]
    @league = league
    @draft_pick = draft_pick
    @user = user
  end

  def call
    return unless valid?

    draft_player if player_id
    mini_draft_pick if mini_draft

    return if errors.any?

    DraftPicks::BroadcastJob.perform_later(draft_pick.id)

    return if league.incomplete_draft_picks?

    Leagues::ActivateJob.perform_later(league.id)
  end

  private

  def draft_player
    draft_pick.update(player: player)
    errors.merge!(draft_pick.errors)

    fpl_team.players << player
    errors.merge!(fpl_team.errors)
  end

  def mini_draft_pick
    draft_pick.update(mini_draft: mini_draft)

    errors.merge!(draft_pick.errors)

    mini_draft_pick_number = fpl_teams.where.not(mini_draft_pick_number: nil).count + 1

    fpl_team.update(mini_draft_pick_number: mini_draft_pick_number)
  end

  def valid_player
    @player = Player.find_by(id: player_id)

    errors.add(:base, 'Player is invalid') if @player.blank?
  end

  def valid_data
    return if (player_id && !mini_draft) || (mini_draft && !player_id)

    errors.add(:base, 'Either select a player or a mini draft pick number')
  end

  def league_status
    return if league.draft?

    errors.add(:base, 'You cannot draft players at this time')
  end

  def user_is_fpl_team_owner
    return if fpl_team.owner == user

    errors.add(:base, 'You are not authorised to perform this action')
  end

  def draft_pick_is_current
    return if league.current_draft_pick == draft_pick

    errors.add(:base, 'You cannot pick out of turn')
  end

  def valid_player_count
    return if fpl_team.players.count < FplTeam::QUOTAS[:players]

    errors.add(:base, "You are only allowed #{FplTeam::QUOTAS[:players]} players in a team")
  end

  def valid_position
    position_name = player.position.plural_name.downcase
    quota = FplTeam::QUOTAS[position_name.to_sym]

    position_count = fpl_team.players.public_send(position_name).count
    return if position_count < quota

    errors.add(:base, "You cannot have more than #{quota} #{position_name} in your team")
  end

  def valid_mini_draft_pick
    return unless (fpl_team.draft_picks.find_by(mini_draft: true) || fpl_team.mini_draft_pick_number) && mini_draft

    errors.add(:base, 'You have already selected your position in the mini draft')
  end

  def player_not_already_picked
    return unless league.players.include?(player)

    errors.add(:base, "#{player.name} has already been picked")
  end

  def maximum_number_of_players_from_team
    return if fpl_team.teams.empty?
    return if fpl_team.players.where(team: player.team).count < FplTeam::QUOTAS[:team]

    errors.add(
      :base,
      "You cannot have more than #{FplTeam::QUOTAS[:team]} players from the same team (#{player.team.name})"
    )
  end
end
