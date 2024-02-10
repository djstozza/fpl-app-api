# Create all draft based on the order
class Leagues::CreateDraft < Leagues::BaseService
  validate :user_is_owner
  validate :league_status
  validate :min_fpl_team_quota

  def initialize(league, user)
    @league = league
    @fpl_teams_count = league.fpl_teams_count
    @user = user
  end

  def call
    return unless valid?

    (1..total_picks).each do |i|
      draft_pick = DraftPick.new(pick_number: i, league: league, fpl_team: fpl_team(i))
      draft_pick.save
      errors.merge!(draft_pick.errors)
    end

    league.update(status: 'draft')
    errors.merge!(league.errors)
  end

  private

  def total_picks
    fpl_teams_count * League::PICKS_PER_TEAM
  end

  def fpl_team_index(index)
    divider = index % (2 * fpl_teams_count)
    divider.zero? ? divider : divider - 1
  end

  def fpl_team(index)
    fpl_team_index = fpl_team_index(index)

    if fpl_team_index < fpl_teams_count
      fpl_teams[fpl_team_index % fpl_teams_count]
    else
      fpl_teams.reverse[fpl_team_index % fpl_teams_count]
    end
  end

  def league_status
    return if league.draft_picks_generated?

    errors.add(:base, 'You cannot create a draft at this time')
  end

  def fpl_teams
    @fpl_teams ||= league.fpl_teams.order(:draft_pick_number)
  end
end
