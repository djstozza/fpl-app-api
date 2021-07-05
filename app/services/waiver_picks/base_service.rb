class WaiverPicks::BaseService < ApplicationService
  def user_can_waiver_pick
    return errors.add(:base, 'You are not authorised to perform this action') if fpl_team_list.owner != user
    return unless fpl_team_list_is_current
    return unless Time.current > fpl_team_list.waiver_deadline

    errors.add(:base, 'The waiver deadline has passed')
  end

  def fpl_team_list_is_current
    return true if fpl_team_list.is_current?

    return errors.add(:base, 'The team list is not from the current round')
  end

  def waiver_pick_is_pending
    return if waiver_pick.pending?

    errors.add(:base, 'Only pending waiver picks can be changed')
  end
end
