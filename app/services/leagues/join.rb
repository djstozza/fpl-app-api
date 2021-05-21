# Join a league and create an fpl_team
class Leagues::Join < Leagues::BaseService
  validate :all_valid


  private

  def all_valid
    valid_code
    unique_users
    valid_fpl_team
  end

  def valid_code
    return if league.code == code

    errors.add(:code, 'is incorrect')
  end

  def unique_users
    return unless league.users.include?(user)

    errors.add(:base, 'You have already joined this league')
  end
end
