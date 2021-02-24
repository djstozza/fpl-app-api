# Populate players service
class Players::Populate < ApplicationService
  def call
    response.each do |player_json|
      player = Player.find_or_create_by(external_id: player_json['id'])

      position = Position.find_by(external_id: player_json['element_type'])
      team = Team.find_by(external_id: player_json['team'])

      player.update!(
        first_name: player_json['first_name'],
        last_name: player_json['second_name'],
        position: position,
        team: team,
        chance_of_playing_next_round: player_json['chance_of_playing_next_round'],
        chance_of_playing_this_round: player_json['chance_of_playing_this_round'],
        code: player_json['code'],
        dreamteam_count: player_json['dreamteam_count'],
        event_points: player_json['event_points'],
        form: player_json['form'],
        in_dreamteam: player_json['in_dreamteam'],
        news: player_json['news'],
        news_added: player_json['news_added'],
        photo: player_json['photo'],
        points_per_game: player_json['points_per_game'],
        special: player_json['special'],
        selected_by_percent: player_json['selected_by_percent'],
        status: player_json['status'],
        total_points: player_json['total_points'],
        minutes: player_json['minutes'],
        goals_scored: player_json['goals_scored'],
        assists: player_json['assists'],
        clean_sheets: player_json['clean_sheets'],
        goals_conceded: player_json['goals_conceded'],
        own_goals: player_json['own_goals'],
        penalties_saved: player_json['penalties_saved'],
        penalties_missed: player_json['penalties_missed'],
        yellow_cards: player_json['yellow_cards'],
        saves: player_json['saves'],
        bonus: player_json['bonus'],
        bps: player_json['bps'],
        influence: player_json['influence'],
        creativity: player_json['creativity'],
        threat: player_json['threat'],
        ict_index: player_json['ict_index'],
      )
    end
  end

  private

  def response
    @response ||= ::HTTParty.get(bootstrap_static_url)['elements']
  end
end
