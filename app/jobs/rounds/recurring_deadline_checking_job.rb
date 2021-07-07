class Rounds::RecurringDeadlineCheckingJob < ApplicationJob
  def perform
    round = Round.current
    return unless round

    check_waiver_deadline(round)
    check_deadline_time(round)
  end

  private

  def check_waiver_deadline(round)
    return unless Time.current.to_date == round.waiver_deadline.to_date
    return if WaiverPick.pending.empty?

    WaiverPicks::ProcessingJob.set(wait_until: round.waiver_deadline).perform_later(round.id)
  end

  def check_deadline_time(round)
    return unless Time.current.to_date == round.deadline_time.to_date
    return if InterTeamTradeGroup.pending.empty?

    InterTeamTradeGroups::ExpireJob.set(wait_until: round.deadline_time_as_time).perform_later(round.id)
  end
end
