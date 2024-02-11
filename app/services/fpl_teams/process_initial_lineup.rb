# Create the first lineup for an fpl_team
class FplTeams::ProcessInitialLineup < ApplicationService
  attr_reader :fpl_team, :round, :fpl_team_list

  validate :valid_fpl_team_list

  def initialize(fpl_team)
    @fpl_team = fpl_team
    @round = Round.current
    @fpl_team_list = FplTeamList.new
  end

  def call
    return unless valid?

    starting_lineup.each do |player|
      list_position = ListPosition.create(player: player, fpl_team_list: fpl_team_list, role: 'starting')
      errors.merge!(list_position.errors) if list_position.errors.any?
    end

    left_over_players = players.where.not(id: starting_lineup.pluck(:id))

    create_substitutes(left_over_players)
  end

  private

  def valid_fpl_team_list
    fpl_team_list.update(fpl_team: fpl_team, round: round)
    errors.merge!(fpl_team_list.errors) if fpl_team_list.errors.any?
  end

  def players
    @players ||= fpl_team.players.order(ict_index: :desc)
  end

  def default_forwards
    @default_forwards ||= players.forwards.first(FplTeamList::MINIMUM_POSITION_COUNTS[:forwards])
  end

  def default_defenders
    @default_defenders ||= players.defenders.first(FplTeamList::MINIMUM_POSITION_COUNTS[:defenders])
  end

  def default_goal_keepers
    @default_goal_keepers ||= players.goalkeepers.first(FplTeamList::MINIMUM_POSITION_COUNTS[:goalkeepers])
  end

  def default_starting_lineup
    @default_starting_lineup ||= default_forwards + default_defenders + default_goal_keepers
  end

  def starting_remainder
    FplTeamList::STARTING_LIST_POSITION_COUNT - default_starting_lineup.count
  end

  def starting_lineup
    default_starting_lineup +
      players
      .outfielders
      .where.not(id: [*default_forwards.pluck(:id), *default_defenders.pluck(:id)])
      .first(starting_remainder)
  end

  def create_substitutes(left_over_players)
    i = 0

    left_over_players.each do |player|
      list_position = ListPosition.new(
        player: player,
        fpl_team_list: fpl_team_list,
      )

      if player.goalkeeper?
        list_position.role = 'substitute_gkp'
      else
        i += 1
        list_position.role = "substitute_#{i}"
      end

      list_position.save

      errors.merge!(list_position.errors)
    end
  end
end
