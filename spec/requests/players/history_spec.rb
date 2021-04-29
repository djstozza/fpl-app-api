require 'rails_helper'

RSpec.describe 'api/players/:player_id/history', :no_transaction, type: :request do
  include StubRequestHelper

  before do
    stub_bootstrap_static_request
    Rounds::Populate.call
    Positions::Populate.call
    Teams::Populate.call
    Players::Populate.call
    stub_fixture_request
    Fixtures::Populate.call
    @player = Player.first
    stub_player_summary_request(@player.external_id)
    Players::PopulateSummary.call(@player)
  end

  it 'returns the history of a player in sorted order' do
    api.get api_player_history_index_url(@player), params: { sort: { kickoff_time: 'desc' } }

    expect(api.data).to match([
      {
        'kickoff_time' => '2020-09-19T19:00:00Z',
        'minutes' => 90,
        'goals_scored' => 0,
        'assists' => 1,
        'saves' => 0,
        'own_goals' => 0,
        'leg' => 'H',
        'total_points' => 5,
        'clean_sheets' => 0,
        'home_team_score' => 2,
        'away_team_score' => 1,
        'yellow_cards' => 0,
        'red_cards' => 0,
        'penalties_saved' => 0,
        'penalties_missed' => 0,
        'bonus' => 0,
        'started' => true,
        'result' => 'W',
        'opponent' => a_hash_including('short_name' => 'WHU'),
        'round' => a_hash_including('name' => 'Gameweek 2'),
      },
      {
        'kickoff_time' => '2020-09-12T11:30:00Z',
        'minutes' => 90,
        'goals_scored' => 1,
        'assists' => 0,
        'saves' => 0,
        'own_goals' => 0,
        'leg' => 'A',
        'total_points' => 7,
        'clean_sheets' => 1,
        'home_team_score' => 0,
        'away_team_score' => 3,
        'yellow_cards' => 1,
        'red_cards' => 0,
        'penalties_saved' => 0,
        'penalties_missed' => 0,
        'bonus' => 0,
        'started' => true,
        'result' => 'W',
        'opponent' => a_hash_including('short_name' => 'FUL'),
        'round' => a_hash_including('name' => 'Gameweek 1'),
      }
    ])
  end
end
