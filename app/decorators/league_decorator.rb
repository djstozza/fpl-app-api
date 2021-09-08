class LeagueDecorator < Draper::Decorator
  delegate_all

  def current_mini_draft_pick
    return unless next_fpl_team

    seasonal_mini_draft_picks.build(pick_number: next_mini_draft_pick_number, fpl_team: next_fpl_team, season: season)
  end

  def next_fpl_team
    return if ordered_fpl_teams.blank?

    if fpl_team_index < fpl_team_count
      ordered_fpl_teams[fpl_team_index % fpl_team_count]
    else
      ordered_fpl_teams.reverse[fpl_team_index % fpl_team_count]
    end
  end

  def fpl_team_divider
    next_mini_draft_pick_number % (2 * fpl_team_count)
  end

  def fpl_team_index
    fpl_team_divider.zero? ? fpl_team_divider : fpl_team_divider - 1
  end

  def mini_draft_status_hash(fpl_team, user)
    {
      round: RoundSerializer.new(round),
      fpl_team_list_id: fpl_team.fpl_team_lists.find_by(round: round).to_param,
      can_make_mini_draft_pick: next_fpl_team == fpl_team && next_fpl_team.owner == user,
      mini_draft_finished: next_fpl_team.nil?,
      season: season,
    }
  end

  def season
    @season ||= Time.current > Round.winter_mini_draft_deadline ? 'winter' : 'summer'
  end

  private

  def next_mini_draft_pick_number
    (seasonal_mini_draft_picks.last&.pick_number || 0) + 1
  end

  def seasonal_mini_draft_picks
    @seasonal_mini_draft_picks ||= mini_draft_picks.where(season: season).order(:pick_number)
  end

  def active_fpl_teams
    @active_fpl_teams ||= fpl_teams.where(id: [*active_fpl_team_ids])
  end

  def active_fpl_team_ids
    SqlQuery.load(
      'mini_draft_picks/fpl_teams_query',
      league_id: league.id,
      season: MiniDraftPick.seasons[season],
    ).get(:ids)
  end

  def ordered_fpl_teams
    @ordered_fpl_teams ||= if season == 'summer'
                             active_fpl_teams.order(mini_draft_pick_number: :asc)
                           else
                             active_fpl_teams.order(rank: :desc)
                           end
  end

  def fpl_team_count
    fpl_teams.count
  end

  def round
    @round ||=
      Round
      .order(:deadline_time)
      .find_by(
        'deadline_time > ? AND mini_draft = TRUE',
        Round.public_send("#{season}_mini_draft_deadline")
      )
  end
end
