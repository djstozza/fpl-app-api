class WaiverPicks::ProcessingJob < ApplicationJob
  def perform(round_id)
    round = Round.find(round_id)

    return unless round.is_current?
    return if Time.current < round.waiver_deadline

    League.live.each do |league|
      waiver_picks = league.waiver_picks.pending
      pick_numbers =  waiver_picks.pluck(:pick_number).uniq.sort

      pick_numbers.each do |pick_number|
        waiver_picks.where(pick_number: pick_number).order('fpl_teams.rank DESC').each do |waiver_pick|
          WaiverPicks::Approve.call(waiver_pick)
        end
      end

      league.waiver_picks.pending.update_all(status: 'declined')
    end
  end
end
