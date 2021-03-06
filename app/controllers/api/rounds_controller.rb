class Api::RoundsController < ApplicationController
  load_resource :round, only: [:show]

  # GET /api/rounds
  def index
    respond_with RoundSerializer.map(Round.order(:deadline_time))
  end

  # GET /api/rounds/1
  def show
    query = RoundDetailQuery.new(round)
    respond_with query if stale?(query)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def round
    @round ||= Round.find(params[:id])
  end
end
