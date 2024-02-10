# Generate draft picks for the league
class Leagues::GenerateDraftPick < Leagues::BaseService
  validate :league_status
  validate :user_is_owner
  validate :min_fpl_team_quota

  def initialize(league, user)
    @league = league
    @fpl_teams_count = league.fpl_teams_count
    @user = user
  end

  def call
    return unless valid?

    fpl_teams.update_all(draft_pick_number: nil)

    assign_draft_picks

    league.update(status: 'draft_picks_generated')
    errors.merge!(league.errors) if league.errors.any?
  end

  private

  def shuffled_fpl_teams
    @shuffled_fpl_teams ||= fpl_teams.includes(:owner).shuffle
  end

  def assign_draft_picks
    shuffled_fpl_teams.each do |fpl_team|
      fpl_team.update(draft_pick_number: (shuffled_fpl_teams.index(fpl_team) + 1))
      errors.merge!(fpl_team.errors) if fpl_team.errors.any?
    end
  end

  def league_status
    return if league.initialized? || league.draft_picks_generated?

    errors.add(:base, 'Draft has already been created')
  end
end
