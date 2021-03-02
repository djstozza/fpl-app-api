# Process team stats based on fixture data since fantasypermierleague/api doesn't readily provide this data
class Teams::ProcessStats < ApplicationService
  WINNING_POINTS = 3

  def call
    SqlQuery.run('fixtures/process_team_stats', winning_points: WINNING_POINTS)
  end
end
