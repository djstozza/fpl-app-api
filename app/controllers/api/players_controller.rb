class Api::PlayersController < ApplicationController
  load_resource :player, only: [:show]

  # GET /api/players
  def index
    respond_with PlayerSerializer.map(players)
  end

  # GET /api/players/1
  def show
    respond_with PlayerSerializer.new(player)
  end

  private

  def players
    @players ||= Player.includes(:position, :team)
  end

  def player
    @player ||= players.find(params[:id])
  end
end
