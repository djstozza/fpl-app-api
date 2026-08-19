# Populate an individual player's summary, throttled against the FPL API
class Players::PopulateSummaryJob < ApplicationJob
  include Sidekiq::Throttled::Job

  sidekiq_throttle(
    threshold: { limit: 3, period: 1.second },
  )

  def perform(player_id)
    Players::PopulateSummary.call(Player.find(player_id))
  end
end
