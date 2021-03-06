class Api::Leagues::DraftPicksController < Api::LeaguesController
  load_resource :draft_pick, only: [:update]

  # GET api/leagues/league_id/draft_picks
  def index
    respond_with draft_picks_query.results, total: total_query(draft_picks_query)
  end

  # PUT api/leagues/league_id/draft_picks/id
  def update
    service = Leagues::UpdateDraftPick.call(league_params, league, draft_pick, current_user)

    respond_with service.errors.any? ? service : draft_picks_query.results, total: total_query(draft_picks_query)
  end

  private

  def league_params
    params.require(:league).permit(:player_id, :mini_draft)
  end

  def draft_picks_query
    @draft_picks_query ||= SqlQuery.load(
      'leagues/draft_picks/index',
      team_id: compacted_params(filter_params[:team_id]),
      position_id: compacted_params(filter_params[:position_id]),
      fpl_team_id: compacted_params(filter_params[:fpl_team_id]),
      league_id: league.id,
      mini_draft: filter_params[:mini_draft],
      sort: sort_query,
    )
  end

  def draft_pick
    @draft_pick ||= league.draft_picks.find(params[:id])
  end

  def filter_params
    params.fetch(:filter, {}).permit(
      :position_id,
      :team_id,
      :mini_draft,
      :fpl_team_id,
      :league_id,
    )
  end

  def sort_params
    permitted =
      params.fetch(:sort, {}).permit(
        :pick_number,
        'players.first_name',
        'players.last_name',
        'teams.short_name',
        'positions.singular_name_short',
        'fpl_teams.name',
        'users.username',
      )

    permitted[:pick_number] ||= 'asc'
    permitted
  end
end
