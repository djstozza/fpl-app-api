# Activate the league once all draft picks have been filled
class Leagues::ActivateJob < ApplicationJob
  def perform(league_id)
    league = League.find(league_id)

    Leagues::Activate.call(league)
  end
end
