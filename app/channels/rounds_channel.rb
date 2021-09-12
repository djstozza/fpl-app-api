class RoundsChannel < ApplicationCable::Channel
  def subscribed
    reject if Round.find_by(id: params[:round_id]).blank?

    stream_from "round_#{params[:round_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
