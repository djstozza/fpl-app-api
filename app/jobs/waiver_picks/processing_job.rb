class WaiverPicks::ProcessingJob < ApplicationJob
  def perform(round_id)
    round = Round.find(round_id)

    return unless round.is_current?
    return if Time.current < round.waiver_deadline

    League.live.each do |league|
      waiver_picks = waiver_picks(league, round)
      pick_numbers =  waiver_picks.pluck(:pick_number).uniq

      pick_numbers.each do |pick_number|
        ordered_waiver_picks_by_rank(waiver_picks, pick_number).each do |waiver_pick|
          WaiverPicks::Approve.call(waiver_pick)

        end
      end

      league.waiver_picks.pending.update_all(status: 'declined')
    end
  end

  private

  def waiver_picks(league, round)
    league
      .waiver_picks
      .pending
      .joins(:fpl_team_list)
      .where('fpl_team_lists.round_id = ?', round.id)
  end

  def ordered_waiver_picks_by_rank(waiver_picks, pick_number)
    waiver_picks
      .where(pick_number: pick_number)
      .order('fpl_teams.rank DESC')
  end
end
