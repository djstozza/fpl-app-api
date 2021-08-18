class Leagues::ProcessFplTeamListsJob < ApplicationJob
  def perform
    League.live.each { |league| Leagues::ProcessFplTeamLists.new(league).call }
  end
end
