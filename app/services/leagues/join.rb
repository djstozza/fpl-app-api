# Join a league and create an fpl_team
class Leagues::Join < Leagues::BaseService
  validate :valid_code
  validate :unique_users
  validate :within_quota
  validate :valid_fpl_team


  private

  def valid_code
    return if league.code == code

    errors.add(:code, 'is incorrect')
  end

  def unique_users
    return unless league.users.include?(user)

    errors.add(:base, 'You have already joined this league')
  end

  def within_quota
    return unless league.fpl_teams.length == League::MAX_FPL_TEAM_QUOTA

    errors.add(:base, 'This league has no more spaces left')
  end
end
