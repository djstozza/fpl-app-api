# Process fixture stats for teams
class Teams::ProcessStatsJob < ApplicationJob
  def perform
    Teams::ProcessStats.call
  end
end
