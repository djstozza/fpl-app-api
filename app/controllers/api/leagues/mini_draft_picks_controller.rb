class Api::Leagues::MiniDraftPicksController < Api::LeaguesController
  load_resource :league

  before_action :check_cache

  def index
    respond_with query
  end

  private

  def query
    SqlQuery.results(
      'mini_draft_picks/index',
      league_id: league.id,
      season: MiniDraftPick.seasons[mini_draft_pick_params[:season]],
    )
  end

  def mini_draft_pick_params
    params.require(:mini_draft_pick).permit(:season)
  end

  def check_cache
    result = SqlQuery.run(
      'mini_draft_picks/index_cache',
      season: MiniDraftPick.seasons[mini_draft_pick_params[:season]],
      league_id: league.id
    ).first
    stale?(etag: result.values, last_modified: result[:last_modified])
  end
end
