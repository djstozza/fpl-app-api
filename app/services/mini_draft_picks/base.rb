class MiniDraftPicks::Base < ApplicationService
  attr_reader :out_player,
              :in_player_id,
              :in_player,
              :passed,
              :list_position,
              :fpl_team_list,
              :fpl_team,
              :league,
              :user

  validate :user_is_owner
  validate :mini_draft?
  validate :user_can_mini_draft
  validate :next_fpl_team?

  private

  def next_fpl_team?
    return if league.current_mini_draft_pick.fpl_team == fpl_team

    errors.add(:base, 'It is not your turn to make a mini draft pick')
  end

  def user_can_mini_draft
    return errors.add(:base, 'The round is not current') unless fpl_team_list.current?
    return errors.add(:base, 'The mini draft is not open yet') unless Time.current > Round.mini_draft_deadline
    return unless Time.current > fpl_team_list.waiver_deadline

    errors.add(:base, 'The mini draft is now closed')
  end

  def user_is_owner
    errors.add(:base, 'You are not authorised to perform this action') unless fpl_team.owner == user
  end

  def mini_draft?
    errors.add(:base, 'The mini draft is not active') unless fpl_team_list.mini_draft
  end

  def current_mini_draft_pick
    league.current_mini_draft_pick
  end
end
