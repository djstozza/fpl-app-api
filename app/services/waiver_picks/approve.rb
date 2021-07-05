class WaiverPicks::Approve < WaiverPicks::BaseService
  attr_reader :waiver_pick, :fpl_team, :fpl_team_list, :out_player, :in_player

  validate :fpl_team_list_is_current
  validate :waiver_deadline_reached
  validate :waiver_pick_is_pending

  def initialize(waiver_pick)
    @waiver_pick = waiver_pick
    @fpl_team_list = waiver_pick.fpl_team_list
    @fpl_team = waiver_pick.fpl_team
    @out_player = waiver_pick.out_player
    @in_player = waiver_pick.in_player
  end

  def call
    return unless valid?

    list_position = fpl_team_list.list_positions.find_by(player: out_player)

    return unless list_position
    return if fpl_team.players.include?(in_player) # In player already part fo the fpl team
    return if fpl_team.league.players.include?(in_player) # In player already picked by an fpl_team in the league

    list_position.update(player: in_player)
    errors.merge!(list_position.errors) if list_position.errors.any?

    fpl_team.players.delete(out_player)
    fpl_team.players << in_player

    waiver_pick.update(status: 'approved')
    errors.merge!(waiver_pick.errors) if waiver_pick.errors.any?
  end

  private

  def waiver_deadline_reached
    return if Time.current > fpl_team_list.waiver_deadline

    errors.add(:base, 'The waiver deadline has not passed yet')
  end
end
