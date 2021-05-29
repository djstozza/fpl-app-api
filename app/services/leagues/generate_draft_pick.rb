# Generate draft picks for the league
class Leagues::GenerateDraftPick < Leagues::BaseService
  validate :league_status
  validate :user_is_owner
  validate :min_fpl_team_quota

  def initialize(league, user)
    @league = league
    @user = user
  end

  def call
    return unless valid?

    shuffled_fpl_teams.each do |fpl_team|
      fpl_team.update(draft_pick_number: (shuffled_fpl_teams.index(fpl_team) + 1))
      errors.merge!(fpl_team.errors) if fpl_team.errors.any?
    end

    league.update(status: 'draft_picks_generated')
    errors.merge!(league.errors) if league.errors.any?
  end

  private

  def shuffled_fpl_teams
    @shuffled_fpl_teams ||= fpl_teams.includes(:owner).shuffle
  end

  def league_status
    return if league.initialized?

    errors.add(:base, 'Draft pick numbers have already been assigned')
  end
end
