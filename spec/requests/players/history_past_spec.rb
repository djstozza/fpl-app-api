require 'rails_helper'

RSpec.describe 'api/players/:player_id/history_past', :no_transaction, type: :request do
  include StubRequestHelper

  before do
    stub_bootstrap_static_request

    Positions::Populate.call
    Teams::Populate.call
    Players::Populate.call
    @player = Player.first
    stub_player_summary_request(@player.external_id)
    Players::PopulateSummary.call(@player)
  end

  it 'returns the past_history of a player in sorted order' do
    api.get api_player_history_past_index_url(@player), params: { sort: { minutes: 'desc' } }

    expect(api.data).to match([
      {
        'season_name' => '2019/20',
        'minutes' => 3136,
        'total_points' => 205,
        'goals_scored' => 22,
        'assists' => 5,
        'saves' => 0,
        'clean_sheets' => 10,
        'yellow_cards' => 3,
        'red_cards' => 1,
        'goals_conceded' => 44,
        'penalties_saved' => 0,
        'penalties_missed' => 0,
        'own_goals' => 0,
        'bonus' => 37,
      },
      {
        'season_name' => '2018/19',
        'minutes' => 2722,
        'total_points' => 205,
        'goals_scored' => 22,
        'assists' => 7,
        'saves' => 0,
        'clean_sheets' => 7,
        'yellow_cards' => 0,
        'red_cards' => 0,
        'goals_conceded' => 42,
        'penalties_saved' => 0,
        'penalties_missed' => 1,
        'own_goals' => 0,
        'bonus' => 32,
      },
      {
        'season_name' => '2017/18',
        'minutes' => 1056,
        'total_points' => 87,
        'goals_scored' => 10,
        'assists' => 4,
        'saves' => 0,
        'clean_sheets' => 4,
        'yellow_cards' => 0,
        'red_cards' => 0,
        'goals_conceded' => 15,
        'penalties_saved' => 0,
        'penalties_missed' => 1,
        'own_goals' => 0,
        'bonus' => 12,
      },
    ])
  end
end
