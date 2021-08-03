class Api::PlayersController < ApplicationController
  load_resource :player, only: [:show]

  # GET /api/players
  def index
    respond_with players_query.results, total: total_query(filtered_players_query)
  end

  # GET /api/players/1
  def show
    respond_with PlayerSerializer.new(player, team: true, history_past: true, history: true)
  end

  def players_query
    SqlQuery.load(
      'players/index',
      players: filtered_players_query,
      sort: sort_query,
      offset: page_params[:offset],
      limit: page_params[:limit],
    )
  end

  def filtered_players_query
    @filtered_players_query ||= SqlQuery.load(
      'players/filtered',
      team_id: Array(filter_params[:team_id]&.split(',').presence).compact,
      position_id: Array(filter_params[:position_id]&.split(',').presence).compact,
      league_id: filter_params[:league_id],
    )
  end

  private

  def player
    @player ||= Player.find(params[:id])
  end

  def filter_params
    params.fetch(:filter, {}).permit(
      :position_id,
      :team_id,
      :league_id,
    )
  end

  def sort_params
    permitted = params.fetch(:sort, {}).permit(
      :last_name,
      :first_name,
      'teams.short_name',
      'positions.singular_name_short',
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

    permitted[:total_points] ||= 'desc'

    permitted
  end

  def page_params
    params.fetch(:page, {}).permit(:limit, :offset)
  end
end
