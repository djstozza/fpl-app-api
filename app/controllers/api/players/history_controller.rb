module Api::Players
  class HistoryController < Api::PlayersController
    # GET /api/players/1/history
    def index
      respond_with  SqlQuery.run(
        'players/history',
        player_id: params[:player_id],
        sort: SqlQuery.lit(sort_params.to_h.map { |k, v| "#{k} #{v}" }.join(', '))
      )
    end

    private

    def sort_params
      params.fetch(:sort, {}).permit(
        :kickoff_time,
        :minutes,
        :total_points,
        :goals_scored,
        :assists,
        :clean_sheets,
        :yellow_cards,
        :red_cards,
        :bonus,
        :saves,
        :penalties_saved,
        :penalties_missed,
        :own_goals,
        :leg,
        'opposition_team.short_name',
        'rounds.deadline_time',
        :result,
      )
    end
  end
end
