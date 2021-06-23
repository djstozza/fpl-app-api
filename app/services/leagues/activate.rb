# Activate the laguea and process the initial lineup of all the fpl_teams
class Leagues::Activate < Leagues::BaseService
  attr_reader :league

  validate :league_status
  validate :draft_picks_completed


  def initialize(league)
    @league = league
  end

  def call
    return unless valid?

    league.fpl_teams.each do |fpl_team|
      fpl_team_service = FplTeams::ProcessInitialLineup.call(fpl_team)
      errors.merge!(fpl_team_service.errors) if fpl_team_service.errors.any?
    end

    league.update(status: 'live')
    errors.merge!(league.errors) if league.errors.any?
  end

  private

  def league_status
    return if league.draft?

    errors.add(:league, 'cannot be activated at this time')
  end

  def draft_picks_completed
    return unless league.has_incomplete_draft_picks?

    errors.add(:base, 'The draft has not been completed yet')
  end
end
