class Api::PositionsController < ApplicationController
  # GET /api/positions
  def index
    respond_with PositionSerializer.map(Position.all)
  end
end
