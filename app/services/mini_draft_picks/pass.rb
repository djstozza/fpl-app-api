class MiniDraftPicks::Pass < MiniDraftPicks::Base
  validate :passed?

  def initialize(data, fpl_team_list, user)
    @passed = data[:passed]
    @fpl_team_list = fpl_team_list
    @fpl_team = fpl_team_list.fpl_team
    @league = fpl_team_list.league.decorate
    @user = user
  end

  def call
    return unless valid?

    pass_mini_draft_pick

    return if errors.any?

    MiniDraftPicks::BroadcastJob.perform_later(MiniDraftPick.last)
  end

  private

  def passed?
    errors.add(:base, 'Passed is required') unless passed
  end

  def pass_mini_draft_pick
    current_mini_draft_pick.update(passed: true)
  end
end
