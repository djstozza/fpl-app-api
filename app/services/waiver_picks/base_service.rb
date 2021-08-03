class WaiverPicks::BaseService < ApplicationService
  def user_can_waiver_pick
    return errors.add(:base, 'You are not authorised to perform this action') if fpl_team_list.owner != user
    return errors.add(:base, 'You cannot make waiver picks during the mini draft') if fpl_team_list.mini_draft
    return unless fpl_team_list_is_current
    return unless Time.current > fpl_team_list.waiver_deadline

    errors.add(:base, 'The waiver deadline has passed')
  end

  def fpl_team_list_is_current
    return true if fpl_team_list.current?

    errors.add(:base, 'The team list is not from the current round')
  end

  def waiver_pick_pending?
    return if waiver_pick.pending?

    errors.add(:base, 'Only pending waiver picks can be changed')
  end
end
