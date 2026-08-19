# Populate player summaries service
class Players::PopulateSummaries < BasePopulateService
  # element-summary is a per-player endpoint, so this fans out into one
  # request per player. Throttled via Players::PopulateSummaryJob to avoid
  # tripping the FPL API's rate limiting.
  def call
    Player.all.find_each { |player| Players::PopulateSummaryJob.perform_later(player.id) }
  end
end
