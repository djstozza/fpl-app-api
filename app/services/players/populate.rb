# Populate players service
class Players::Populate < BasePopulateService
  ATTRS = %w[
    first_name
    chance_of_playing_next_round
    chance_of_playing_this_round
    code
    dreamteam_count
    event_points
    form
    in_dreamteam
    news
    news_added
    photo
    points_per_game
    special
    selected_by_percent
    status
    total_points
    minutes
    goals_scored
    assists
    clean_sheets
    goals_conceded
    own_goals
    penalties_saved
    penalties_missed
    yellow_cards
    red_cards
    saves
    bonus
    bps
    influence
    creativity
    threat
    ict_index
  ].freeze

  def call
    response.each do |player_json|
      player = Player.find_or_create_by(external_id: player_json['id'])

      player.update!(
        team: team(player_json['team']),
        position: position(player_json['element_type']),
        last_name: player_json['second_name'],
        **player_json.slice(*ATTRS),
      )
    end
  end

  private

  def response
    @response ||= ::HTTParty.get(bootstrap_static_url)['elements']
  end

  def team(external_id)
    Team.find_by(external_id: external_id)
  end

  def position(external_id)
    Position.find_by(external_id: external_id)
  end
end
