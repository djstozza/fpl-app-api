module Api::Players
  class HistoryPastController < Api::PlayersController
    # GET /api/players/1/history
    def index
      respond_with SqlQuery.run(
        'players/history_past',
        player_id: params[:player_id],
        sort: SqlQuery.lit(sort_params.to_h.map { |k, v| "#{k} #{v}" }.join(', '))
      )
    end

    private

    def sort_params
      params.fetch(:sort, {}).permit(
        :season_name,
        :minutes,
        :total_points,
        :goals_scored,
        :assists,
        :saves,
        :clean_sheets,
        :goals_conceded,
        :yellow_cards,
        :red_cards,
        :penalties_saved,
        :penalties_missed,
        :own_goals,
        :bonus
      )
    end
  end
end
