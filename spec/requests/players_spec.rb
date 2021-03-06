require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to test the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator. If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails. There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.

RSpec.describe 'api/players', :no_transaction, type: :request do
  let(:team1) { create :team }
  let(:team2) { create :team }
  let(:team3) { create :team }
  let!(:player1) { create :player, :forward, team: team3, total_points: 90 }
  let!(:player2) { create :player, :defender, team: team2, total_points: 20 }
  let!(:player3) { create :player, :goalkeeper, team: team1, total_points: 50 }

  describe 'GET /index' do
    it 'renders a sortable list of players' do
      api.get api_players_url, params: { sort: { last_name: 'asc' } }

      expect(response).to be_successful

      expect(api.data).to match(
        [
          a_hash_including(
            'id' => player1.to_param,
            'first_name' => player1.first_name,
            'last_name' => player1.last_name,
            'external_id' => player1.external_id.to_s,
            'position' => {
              'id' => player1.position.to_param,
              'singular_name_short' => 'FWD',
            },
            'team' => a_hash_including(
              'id' => team3.to_param,
              'short_name' => team3.short_name,
            ),
          ),
          a_hash_including(
            'id' => player2.to_param,
            'first_name' => player2.first_name,
            'last_name' => player2.last_name,
            'external_id' => player2.external_id.to_s,
            'position' => {
              'id' => player2.position.to_param,
              'singular_name_short' => 'DEF',
            },
            'team' => a_hash_including(
              'id' => team2.to_param,
              'short_name' => team2.short_name,
            ),
          ),
          a_hash_including(
            'id' => player3.to_param,
            'first_name' => player3.first_name,
            'last_name' => player3.last_name,
            'external_id' => player3.external_id.to_s,
            'position' => {
              'id' => player3.position.to_param,
              'singular_name_short' => 'GKP',
            },
            'team' => a_hash_including(
              'id' => team1.to_param,
              'short_name' => team1.short_name,
            ),
          ),
        ],
      )

      api.get api_players_url, params: { sort: { last_name: 'desc' } }

      expect(api.data).to match(
        [
          a_hash_including(
            'id' => player3.to_param,
          ),
          a_hash_including(
            'id' => player2.to_param,
          ),
          a_hash_including(
            'id' => player1.to_param,
          ),
        ],
      )

      api.get api_players_url, params: { sort: { total_points: 'asc' } }

      expect(api.data).to match(
        [
          a_hash_including(
            'id' => player2.to_param,
          ),
          a_hash_including(
            'id' => player3.to_param,
          ),
          a_hash_including(
            'id' => player1.to_param,
          ),
        ],
      )

      expect(api.meta).to include('total' => 3)
    end

    it 'is filterable' do
      api.get api_players_url, params: {
        filter: { team_id: team2.to_param },
        sort: { total_points: 'asc' },
      }

      expect(api.data).to match(
        [
          a_hash_including(
            'id' => player2.to_param,
          ),
        ],
      )

      expect(api.meta).to include('total' => 1)
    end

    it 'excludes players that have been picked in a league' do
      fpl_team1 = create(:fpl_team)
      fpl_team1.players << player1

      fpl_team2 = create(:fpl_team)
      fpl_team2.players << player2

      api.get api_players_url, params: {
        filter: { league_id: fpl_team1.league.to_param },
        sort: { total_points: 'asc' },
      }

      expect(api.data).to match(
        [
          a_hash_including(
            'id' => player2.to_param,
          ),
          a_hash_including(
            'id' => player3.to_param,
          ),
        ],
      )
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      get api_player_url(player1)

      expect(response).to be_successful

      expect(api.data).to include(
        'id' => player1.to_param,
        'first_name' => player1.first_name,
        'last_name' => player1.last_name,
        'position' => {
          'id' => player1.position.to_param,
          'singular_name' => 'Forward',
          'singular_name_short' => 'FWD',
        },
        'team' => a_hash_including(
          'id' => player1.team.to_param,
          'name' => player1.team.name,
          'short_name' => player1.team.short_name,
        ),
      )
    end
  end
end
