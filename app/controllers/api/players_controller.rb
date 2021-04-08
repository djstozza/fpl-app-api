class Api::PlayersController < ApplicationController
  load_resource :player, only: [:show]

  # GET /api/players
  def index
    respond_with PlayerSerializer.map(players, team: true)
  end

  # GET /api/players/1
  def show
    respond_with PlayerSerializer.new(player, team: true)
  end

  private

  def players
    @players ||= Player
      .includes(:position, :team)
      .where(':team_id IS NULL OR team_id = :team_id', team_id: filter_params[:team_id])
      .order(sort_params.to_h)
  end

  def player
    @player ||= players.find(params[:id])
  end

  def filter_params
    params.fetch(:filter, {}).permit(:team_id)
  end

  def sort_params
    params.fetch(:sort, {}).permit(
      :last_name,
      :first_name,
      :position_id,
      :total_points,
      :goals_scored,
      :assists,
      :clean_sheets,
      :yellow_cards,
      :red_cards,
      :bonus,
      :saves,
      :penalties_saved,
      :penalties_missed,
      :own_goals,
    )
  end
end
