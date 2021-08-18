# Populate teams
class Teams::PopulateJob < ApplicationJob
  def perform
    Teams::Populate.call
    Teams::ProcessStats.call
  end
end
