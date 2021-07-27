require 'rails_helper'

RSpec.describe 'list_positions/:list_position_id/tradeable_list_position_facets', :no_transaction, type: :request do
  let(:round) { create :round }
  let(:league) { create :league }
  let(:fpl_team1) { create :fpl_team, league: league }
  let(:fpl_team2) { create :fpl_team, league: league }
  let(:fpl_team3) { create :fpl_team, league: league }

  let(:fpl_team_list1) { create :fpl_team_list, fpl_team: fpl_team1, round: round }
  let(:fpl_team_list2) { create :fpl_team_list, fpl_team: fpl_team2, round: round }
  let(:fpl_team_list3) { create :fpl_team_list, fpl_team: fpl_team3, round: round }

  let(:position1) { create :position, :forward }
  let(:position2) { create :position, :midfielder }

  let(:player1) { create :player, position: position1 }
  let(:player2) { create :player, position: position1 }
  let(:player3) { create :player, position: position1 }
  let(:player4) { create :player, position: position1 }
  let(:player5) { create :player, position: position2 }


  let!(:list_position1) { create :list_position, player: player1, fpl_team_list: fpl_team_list1 }
  let!(:list_position2) { create :list_position, player: player2, fpl_team_list: fpl_team_list2 }
  let!(:list_position3) { create :list_position, player: player3, fpl_team_list: fpl_team_list2 }
  let!(:list_position4) { create :list_position, player: player4, fpl_team_list: fpl_team_list3 }
  let!(:list_position5) { create :list_position, player: player5, fpl_team_list: fpl_team_list3 }


  before { api.authenticate(fpl_team1.owner) }

  describe 'GET /index' do
    it 'returns a list of tradeable list_position facets' do
      api.get api_list_position_tradeable_list_position_facets_url(list_position1)

      expect(api.response).to have_http_status(:success)

      expect(api.data).to match(
        'teams' => [
          a_hash_including(
            'label' => player2.team.short_name,
            'value' => player2.team.to_param,
          ),
          a_hash_including(
            'label' => player3.team.short_name,
            'value' => player3.team.to_param,
          ),
          a_hash_including(
            'label' => player4.team.short_name,
            'value' => player4.team.to_param,
          ),
        ],
        'fpl_teams' => [
          a_hash_including(
            'label' => fpl_team2.name,
            'value' => fpl_team2.to_param,
          ),
          a_hash_including(
            'label' => fpl_team3.name,
            'value' => fpl_team3.to_param,
          ),
        ],
      )
    end

    it 'only shows players from the listed in_fpl_team_list_id, excluding players included in excluded_player_ids' do
      api.get api_list_position_tradeable_list_position_facets_url(list_position1),
              params: { filter: { in_fpl_team_list_id: fpl_team_list2.id, excluded_player_ids: player2.to_param } }

      expect(api.data).to match(
        'teams' => [
          a_hash_including(
            'label' => player3.team.short_name,
            'value' => player3.team.to_param,
          ),
        ],
        'fpl_teams' => [
          a_hash_including(
            'label' => fpl_team2.name,
            'value' => fpl_team2.to_param,
          ),
        ],
      )
    end
  end
end
