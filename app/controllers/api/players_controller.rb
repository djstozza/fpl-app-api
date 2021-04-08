class Api::PlayersController < ApplicationController
  load_resource :player, only: [:show]

  # GET /api/players
  def index
    respond_with SqlQuery.run(
      'players/index',
      team_id: filter_params[:team_id],
      sort: SqlQuery.lit(sort_params.to_h.map { |k, v| "#{k} #{v}" }.join(', '))
    )
  end

  # GET /api/players/1
  def show
    respond_with PlayerSerializer.new(player, team: true)
  end

  private

  def player
    @player ||= Player.find(params[:id])
  end

  def filter_params
    params.fetch(:filter, {}).permit(:team_id)
  end

  def sort_params
    params.fetch(:sort, {}).permit(
      :last_name,
      :first_name,
      'teams.short_name',
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
