require 'rails_helper'

RSpec.describe Players::PopulateSummary, type: :service do
  include StubRequestHelper

  describe 'call' do
    before do
      stub_bootstrap_static_request

      Positions::Populate.call
      Teams::Populate.call
      Players::Populate.call
    end

    it 'adds history and history_past to the player' do
      player = Player.first
      stub_player_summary_request(player.external_id)

      described_class.call(player)

      expect(player.attributes).to include(
        'history' => including(
          a_hash_including(
            'round' => 1,
            'fixture' => 2,
            'total_points' => 7,
            'goals_scored' => 1,
            'assists' => 0,
            'yellow_cards' => 1,
            'clean_sheets' => 1,
            'minutes' => 90,
          ),
          a_hash_including(
            'round' => 2,
            'fixture' => 9,
            'total_points' => 5,
            'goals_scored' => 0,
            'assists' => 1,
            'clean_sheets' => 0,
            'minutes' => 90,
          ),
          a_hash_including(
            'round' => 3,
            'fixture' => 23,
            'total_points' => 2,
            'goals_scored' => 0,
            'assists' => 0,
            'clean_sheets' => 0,
            'minutes' => 90,
          ),
        ),
        'history_past' => including(
          a_hash_including(
            'season_name' => '2017/18',
            'total_points' => 87,
            'minutes' => 1_056,
            'goals_scored' => 10,
            'assists' => 4,
            'clean_sheets' => 4,
            'bonus' => 12,
          ),
          a_hash_including(
            'season_name' => '2018/19',
            'total_points' => 205,
            'minutes' => 2_722,
            'goals_scored' => 22,
            'assists' => 7,
            'clean_sheets' => 7,
            'penalties_missed' => 1,
            'bonus' => 32,
          ),
          a_hash_including(
            'season_name' => '2019/20',
            'element_code' => 54_694,
            'total_points' => 205,
            'minutes' => 3_136,
            'goals_scored' => 22,
            'assists' => 5,
            'clean_sheets' => 10,
            'yellow_cards' => 3,
            'red_cards' => 1,
            'saves' => 0,
            'bonus' => 37,
          )
        )
      )
    end
  end
end
