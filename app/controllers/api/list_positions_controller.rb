class Api::ListPositionsController < ApplicationController
  before_action :authenticate_user!
  load_resource :list_position, only: [:show]

  def show
    respond_with SqlQuery.load('list_positions/valid_substitutions', list_position_id: list_position.id).result
  end

  private

  def list_position
    @list_position = ListPosition.find(params[:list_position_id] || params[:id])
  end
end
