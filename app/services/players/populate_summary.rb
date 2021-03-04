# Populate player summary service
class Players::PopulateSummary < BasePopulateService

  def initialize(player)
    @player = player
  end

  def call
    player.update!(
      history: history,
      history_past: response['history_past'],
    )
  end

  private

  attr_accessor :player

  def response
    @response ||= ::HTTParty.get(player_summary_url(player.external_id))
  end

  def history
    response['history'].select { |history| history['minutes'] > 0 }
  end
end
