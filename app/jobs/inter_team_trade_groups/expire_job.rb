class InterTeamTradeGroups::ExpireJob < ApplicationJob
  def perform(round_id)
    round = Round.find(round_id)

    return unless round.current?
    return if Time.current < round.deadline_time_as_time

    InterTeamTradeGroup.pending.update_all(status: 'expired')
  end
end
