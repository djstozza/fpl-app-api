# Populate player summaries
class Players::PopulateSummariesJob < ApplicationJob
  def perform
    Players::PopulateSummaries.call
    Leagues::ProcessFplTeamListsJob.perform_later
  end
end
