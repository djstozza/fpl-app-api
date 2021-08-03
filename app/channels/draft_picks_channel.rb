class DraftPicksChannel < ApplicationCable::Channel
  def subscribed
    reject if League.find_by(id: params[:league_id]).blank?

    stream_from "league_#{params[:league_id]}_draft_picks"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
