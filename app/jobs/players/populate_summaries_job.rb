# Populate player summaries
class Players::PopulateSummariesJob < ApplicationJob
  def perform
    Players::PopulateSummaries.call
  end
end
