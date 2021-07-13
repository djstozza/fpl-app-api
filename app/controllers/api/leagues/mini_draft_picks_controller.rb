class Api::Leagues::MiniDraftPicksController < Api::LeaguesController
  load_resource :league

  def index
    respond_with query if stale?(query)
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
end
