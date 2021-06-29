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

    players = fpl_team.players.order(ict_index: :desc)
    default_forwards = players.forwards.first(FplTeamList::MINIMUM_POSITION_COUNTS[:forwards])
    default_defenders = players.defenders.first(FplTeamList::MINIMUM_POSITION_COUNTS[:defenders])
    default_goal_keepers = players.goalkeepers.first(FplTeamList::MINIMUM_POSITION_COUNTS[:goalkeepers])

    starting = []
    starting += default_forwards
    starting += default_defenders
    starting += default_goal_keepers

    remainder = FplTeamList::STARTING_LIST_POSITION_COUNT - starting.count

    starting +=
      players
      .outfielders
      .where.not(id: [*default_forwards.pluck(:id), *default_defenders.pluck(:id)])
      .first(remainder)

    starting.each do |player|
      list_position = ListPosition.create(player: player, fpl_team_list: fpl_team_list, role: 'starting')
      errors.merge!(list_position.errors) if list_position.errors.any?
    end

    left_over_players = players.where.not(id: starting.pluck(:id))

    create_substitutes(left_over_players)
  end

  private

  def valid_fpl_team_list
    fpl_team_list.update(fpl_team: fpl_team, round: round)
    errors.merge!(fpl_team_list.errors) if fpl_team_list.errors.any?
  end

  def create_substitutes(left_over_players)
    i = 0

    left_over_players.each do |player|
      if player.goalkeeper?
        list_position = ListPosition.create(
          player: player,
          fpl_team_list: fpl_team_list,
          role: 'substitute_gkp',
        )

        errors.merge!(list_position.errors) if list_position.errors.any?
      else
        i += 1
        list_position = ListPosition.create(
          player: player,
          fpl_team_list: fpl_team_list,
          role: "substitute_#{i}",
        )

        errors.merge!(list_position.errors) if list_position.errors.any?
      end
    end
  end
end
