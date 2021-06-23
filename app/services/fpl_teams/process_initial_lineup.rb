# Create the first lineup for an fpl_team
class FplTeams::ProcessInitialLineup < ApplicationService
  attr_reader :fpl_team, :round, :fpl_team_list
  validate :valid_fpl_team_list

  def initialize(fpl_team)
    @fpl_team = fpl_team
    @round = Round.find_by(is_current: true) || Round.first
    @fpl_team_list = FplTeamList.new
  end

  def call
    return unless valid?

    players = fpl_team.players.order(ict_index: :desc)
    default_forward = players.forwards.first
    default_goal_keeper = players.goalkeepers.first

    starting = []
    starting << default_forward
    starting += players.outfielders.where.not(id: default_forward.id).first(9)
    starting << default_goal_keeper

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
