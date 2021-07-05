class Rounds::RecurringWaiverDeadlineCheckingJob < ApplicationJob
  def perform
    round = Round.current
    return unless round

    return if Time.current.to_date != round.waiver_deadline.to_date

    pending_waiver_picks = WaiverPick.joins(:fpl_team_list).where('fpl_team_lists.round_id = ?', round.id).pending
    return if pending_waiver_picks.empty?

    WaiverPicks::ProcessingJob.set(wait_until: round.waiver_deadline).perform_later(round.id)
  end
end
