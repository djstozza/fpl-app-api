# Base logic for league services
class Leagues::BaseService < ApplicationService
  attr_reader :league, :name, :fpl_team, :code, :fpl_team_name, :user

  def initialize(data, user, league: nil)
    @league = league || League.new
    @fpl_team = FplTeam.new
    @name = data[:name]
    @fpl_team_name = data[:fpl_team_name]
    @code = data[:code]
    @user = user
  end

  def call
    valid?
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
end
