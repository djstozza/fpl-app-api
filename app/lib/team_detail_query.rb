class TeamDetailQuery
  def initialize(team)
    @team = team
  end

  def as_json(*)
    serializable_team.merge(
      fixtures: fixtures,
      players: players,
    )
  end

  def updated_at
    @updated_at ||= SqlQuery.run('team_detail_query/cache', team_id: team.id).first[:updated_at]
  end

  def cache_key
    updated_at
  end

  private

  attr_reader :team

  def serializable_team
    {
      id: team.to_param,
      name: team.name,
      position: team.position,
      points: team.points,
      form: team.form&.last(5),
      wins: team.wins,
      losses: team.losses,
      draws: team.draws,
      clean_sheets: team.clean_sheets,
      goals_for: team.goals_for,
      goals_against: team.goals_against,
      goal_difference: team.goal_difference,
    }
  end

  def fixtures
    SqlQuery.results('team_detail_query/fixtures', team_id: team.id)
  end

  def players
    SqlQuery.results('team_detail_query/players', team_id: team.id)
  end
end
