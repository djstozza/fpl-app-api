# Update fpl team details
class FplTeams::Update < ApplicationService
  attr_reader :data, :fpl_team, :user

  validate :user_is_owner

  def initialize(data, fpl_team, user)
    @data = data
    @fpl_team = fpl_team
    @user = user
  end

  def call
    return unless valid?

    fpl_team.update(data)
    errors.merge!(fpl_team.errors) if fpl_team.errors.any?
  end

  private

  def user_is_owner
    return if fpl_team.owner == user

    errors.add(:base, 'You are not authorised to perform this action')
  end
end
