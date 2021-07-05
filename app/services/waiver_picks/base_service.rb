class WaiverPicks::BaseService < ApplicationService
  def user_can_waiver_pick
    return errors.add(:base, 'You are not authorised to perform this action') if fpl_team_list.owner != user
    return errors.add(:base, 'Round is not current') unless fpl_team_list.is_current?
    return unless Time.current > fpl_team_list.waiver_deadline

    errors.add(:base, 'The waiver deadline has passed')
  end
end
