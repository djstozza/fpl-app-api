class FplTeamListScoreChannel < ApplicationCable::Channel
  def subscribed
    reject if FplTeamList.find_by(id: params[:fpl_team_list_id]).blank?

    stream_from "fpl_team_list_#{params[:fpl_team_list_id]}_score"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
