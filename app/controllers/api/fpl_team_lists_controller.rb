class Api::FplTeamListsController < ApplicationController
  before_action :authenticate_user!
  load_resource :fpl_team_list, only: [:show, :update]

  # GET /api/fpl_team_lists
  def index
    respond_with FplTeamListSerializer.map(fpl_team_lists)
  end

  # GET /api/fpl_team_lists/1
  def show
    respond_with query[0] if stale?(query)
  end

  # PUT /api/fpl_team_lists/1
  def update
    service = FplTeamLists::ProcessSubstitution.call(fpl_team_list_params.to_h, fpl_team_list, current_user)

    respond_with service.errors.any? ? service : query[0]
  end

  private

  def fpl_team_list
    @fpl_team_list ||= FplTeamList.find(params[:id])
  end

  def query
    @query ||= SqlQuery.results(
      'fpl_team_lists/show',
      list_position_details: list_position_details,
      fpl_team_list_id: fpl_team_list.id,
      user_id: current_user.id,
    )
  end

  def list_position_details
    SqlQuery.load(
      'fpl_team_lists/list_position_details',
      fpl_team_list_id: fpl_team_list.id,
    )
  end

  def fpl_team_lists
    ::FplTeamList.where(fpl_team_id: fpl_team_list_params[:fpl_team_id]).includes(:round).order('rounds.deadline_time')
  end

  def fpl_team_list_params
    params.require(:fpl_team_list).permit(:fpl_team_id, :out_list_position_id, :in_list_position_id)
  end
end
