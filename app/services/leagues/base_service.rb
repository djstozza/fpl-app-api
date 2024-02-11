# Base logic for league services
class Leagues::BaseService < ApplicationService
  attr_reader :league,
              :name,
              :fpl_team,
              :code,
              :fpl_team_name,
              :user,
              :fpl_teams_count

  def initialize(data, user, options = {})
    @league = options[:league] || League.new
    @fpl_team = FplTeam.new
    @name = data[:name]
    @fpl_team_name = data[:fpl_team_name]
    @code = data[:code]
    @user = user
  end

  def call
    nil unless valid?
  end

  private

  def valid_league
    league.update(name: name, code: code, owner: user)

    errors.merge!(league.errors) if league.errors.any?
  end

  def valid_fpl_team
    fpl_team.update(fpl_team_name: fpl_team_name, league: league, owner: user)

    errors.merge!(fpl_team.errors) if fpl_team.errors.any?
  end

  def user_is_owner
    return if league.owner == user

    errors.add(:base, 'You are not authorised to perform this action')
  end

  def min_fpl_team_quota
    return if fpl_teams_count >= League::MIN_FPL_TEAM_QUOTA

    errors.add(:base, "There must be at least #{League::MIN_FPL_TEAM_QUOTA} teams present")
  end

  def fpl_teams
    @fpl_teams ||= league.fpl_teams
  end
end
