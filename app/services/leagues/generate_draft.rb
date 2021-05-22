class Leagues::GenerateDraft < Leagues::BaseService
  attr_reader :league, :user
  validate :league_is_initialized
  validate :user_is_owner

  def initialize(league, user)
    @league = league
    @user = user
  end

  def call
    return unless valid?

    shuffled_fpl_teams.each do |fpl_team|
      fpl_team.assign_attributes(draft_pick_number: (shuffled_fpl_teams.index(fpl_team) + 1))
      fpl_team.save
      errors.merge!(fpl_team.errors) if fpl_team.errors.any?
    end

    league.update(status: 'draft_picks_generated')
    errors.merge!(league.errors) if league.errors.any?
  end

  private

  def shuffled_fpl_teams
    @shuffled_fpl_teams ||= league.fpl_teams.includes(:owner).shuffle
  end

  def league_is_initialized
    return if league.initialized?

    errors.add(:base, 'Draft pick numbers have already been assigned')
  end
end
