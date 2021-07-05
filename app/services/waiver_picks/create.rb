class WaiverPicks::Create < WaiverPicks::BaseService
  attr_reader :fpl_team_list,
              :user,
              :out_player_id,
              :out_player,
              :in_player_id,
              :in_player

  validate :user_can_waiver_pick
  validate :valid_out_player
  validate :valid_in_player
  validate :same_positions
  validate :maximum_number_of_players_from_team
  validate :waiver_pick_is_unique

  def initialize(data, fpl_team_list, user)
    @out_player_id = data[:out_player_id]
    @in_player_id = data[:in_player_id]
    @fpl_team_list = fpl_team_list
    @user = user
  end

  def call
    return unless valid?

    waiver_pick =
      WaiverPick.create(
        pick_number: fpl_team_list.waiver_picks.length + 1,
        out_player: out_player,
        in_player: in_player,
        fpl_team_list: fpl_team_list,
      )

    errors.merge!(waiver_pick.errors) if waiver_pick.errors.any?
  end

  private

  def valid_out_player
    @out_player = fpl_team_list.players.find_by(id: out_player_id)
    return if @out_player.present?

    errors.add(:base, 'The player you have selected to waiver out is not part of your team')
  end

  def valid_in_player
    @in_player = Player.find_by(id: in_player_id)
    errors.add(:base, 'The player you have selected to waiver in does not exist') if @in_player.blank?

    return unless fpl_team_list.league.players.find_by(id: in_player_id)

    errors.add(:base, 'The player you have selected to waiver in is already part of a team in your league')
  end

  def same_positions
    return if out_player.blank? || in_player.blank?
    return if out_player&.position == in_player&.position

    errors.add(:base, 'Players being waivered must have the same positions')
  end

  def maximum_number_of_players_from_team
    return if in_player.blank? || out_player.blank?

    team_ids = fpl_team_list.players.where.not(id: out_player_id).pluck(:team_id)
    team_ids << in_player.team_id

    return if team_ids.count(in_player.team_id) <= FplTeam::QUOTAS[:team]

    errors.add(
      :base,
      "You can't have more than #{FplTeam::QUOTAS[:team]} players from the same team (#{in_player.team.short_name})",
    )
  end

  def waiver_pick_is_unique
    existing_waiver_pick = fpl_team_list.waiver_picks.find_by(in_player: in_player, out_player: out_player)

    return if existing_waiver_pick.nil?

    errors.add(
      :base,
      "Duplicate waiver pick - (Pick number: #{existing_waiver_pick.pick_number} " \
        "Out: #{out_player.name}, In: #{in_player.name})"
    )
  end
end
