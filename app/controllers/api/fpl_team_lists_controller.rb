class Api::FplTeamListsController < ApplicationController
  before_action :authenticate_user!
  load_resource :fpl_team_list, only: [:show, :update]

  # GET /api/fpl_team_lists
  def index
    respond_with FplTeamListSerializer.map(fpl_team_lists)
  end

  # GET /api/fpl_team_lists/1
  def show
    respond_with FplTeamListSerializer.new(fpl_team_list, current_user: current_user)
  end

  # PUT /api/fpl_team_lists/1
  def update
    service = FplTeamLists::ProcessSubstitution.call(fpl_team_list_params.to_h, fpl_team_list, current_user)

    respond_with service.errors.any? ? service : list_positions_query
  end

  private

  def fpl_team_list
    @fpl_team_list ||= FplTeamList.find(params[:fpl_team_list_id] || params[:id])
  end

  def list_positions_query
    SqlQuery.results(
      'fpl_team_lists/list_position_details',
      fpl_team_list_id: fpl_team_list.id,
    )
  end

  def inter_team_trade_groups_query
    SqlQuery.load(
      'inter_team_trade_groups/by_fpl_team_list',
      fpl_team_list_id: fpl_team_list.id,
      user_id: current_user.id,
    )
  end

  def fpl_team_lists
    ::FplTeamList.where(fpl_team_id: fpl_team_list_params[:fpl_team_id]).includes(:round).order('rounds.deadline_time')
  end

  def fpl_team_list_params
    params.require(:fpl_team_list).permit(:fpl_team_id, :out_list_position_id, :in_list_position_id)
  end
end
