require 'rails_helper'

RSpec.describe 'list_positions/:list_position_id/tradeable_list_positions', :no_transaction, type: :request do
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
    it 'returns a list of tradeable list_positions - no params' do
      api.get api_list_position_tradeable_list_positions_url(list_position1)

      expect(api.response).to have_http_status(:success)

      expect(api.data).to match(
        [
          a_hash_including(
            'id' => list_position2.to_param,
            'fpl_team_list_id' => fpl_team_list2.to_param,
            'player' => a_hash_including(
              'id' => player2.to_param,
              'first_name' => player2.first_name,
              'last_name' => player2.last_name,
            ),
            'position' => a_hash_including(
              'id' => position1.to_param,
              'singular_name_short' => position1.singular_name_short,
            ),
            'team' => a_hash_including(
              'id' => player2.team.to_param,
              'short_name' => player2.team.short_name,
            ),
            'fpl_team' => a_hash_including(
              'id' => fpl_team2.to_param,
              'name' => fpl_team2.name,
            ),
          ),
          a_hash_including(
            'id' => list_position3.to_param,
            'fpl_team_list_id' => fpl_team_list2.to_param,
            'player' => a_hash_including(
              'id' => player3.to_param,
              'first_name' => player3.first_name,
              'last_name' => player3.last_name,
            ),
            'position' => a_hash_including(
              'id' => position1.to_param,
              'singular_name_short' => position1.singular_name_short,
            ),
            'team' => a_hash_including(
              'id' => player3.team.to_param,
              'short_name' => player3.team.short_name,
            ),
            'fpl_team' => a_hash_including(
              'id' => fpl_team2.to_param,
              'name' => fpl_team2.name,
            ),
          ),
          a_hash_including(
            'id' => list_position4.to_param,
            'fpl_team_list_id' => fpl_team_list3.to_param,
            'player' => a_hash_including(
              'id' => player4.to_param,
              'first_name' => player4.first_name,
              'last_name' => player4.last_name,
            ),
            'position' => a_hash_including(
              'id' => position1.to_param,
              'singular_name_short' => position1.singular_name_short,
            ),
            'team' => a_hash_including(
              'id' => player4.team.to_param,
              'short_name' => player4.team.short_name,
            ),
            'fpl_team' => a_hash_including(
              'id' => fpl_team3.to_param,
              'name' => fpl_team3.name,
            ),
          ),
        ],
      )
    end

    it 'only shows players from the listed in_fpl_team_list_id, excluding players included in excluded_player_ids' do
      api.get api_list_position_tradeable_list_positions_url(list_position1),
              params: { filter: { in_fpl_team_list_id: fpl_team_list2.id, excluded_player_ids: player2.to_param } }

      expect(api.data).to match(
        [
          a_hash_including(
            'id' => list_position3.to_param,
            'fpl_team_list_id' => fpl_team_list2.to_param,
            'player' => a_hash_including(
              'id' => player3.to_param,
              'first_name' => player3.first_name,
              'last_name' => player3.last_name,
            ),
            'position' => a_hash_including(
              'id' => position1.to_param,
              'singular_name_short' => position1.singular_name_short,
            ),
            'team' => a_hash_including(
              'id' => player3.team.to_param,
              'short_name' => player3.team.short_name,
            ),
            'fpl_team' => a_hash_including(
              'id' => fpl_team2.to_param,
              'name' => fpl_team2.name,
            ),
          ),
        ],
      )
    end

    it 'is sortable' do
      api.get api_list_position_tradeable_list_positions_url(list_position1),
              params: { sort: { 'fpl_teams.name' => 'desc' } }
      expect(api.response).to have_http_status(:success)

      expect(api.data).to match(
        [
          a_hash_including(
            'id' => list_position4.to_param,
          ),
          a_hash_including(
            'id' => list_position2.to_param,
          ),
          a_hash_including(
            'id' => list_position3.to_param,
          ),
        ],
      )
    end
  end
end
