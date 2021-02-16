class Api::PositionsController < ApplicationController
  # GET /api/positions
  def index
    respond_with PositionSerializer.map(Position.order(:singular_name_short))
  end
end
