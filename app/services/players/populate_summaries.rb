# Populate player summaries service
class Players::PopulateSummaries < BasePopulateService
  def call
    Player.all.find_each { |player| Players::PopulateSummary.call(player) }
  end
end
