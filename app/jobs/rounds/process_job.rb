# Populate rounds and trigger the fpl team list processing job after the update
class Rounds::ProcessJob < ApplicationJob
  def perform
    Rounds::Populate.call
    Leagues::ProcessFplTeamListsJob.perform_later
  end
end
