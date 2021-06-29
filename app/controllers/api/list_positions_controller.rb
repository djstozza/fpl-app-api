class Api::ListPositionsController < ApplicationController
  before_action :authenticate_user!
  load_resource :list_position, only: [:show]

  def show
    respond_with SqlQuery.results('list_positions/valid_substitutions', list_position_id: list_position.id)
  end

  private

  def list_position
    @list_position = ListPosition.find(params[:id])
  end
end
