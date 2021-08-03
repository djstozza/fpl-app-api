require 'rails_helper'

RSpec.describe 'api/leagues/league_id/fpl_teams', type: :request do
  let!(:user) { create :user }
  let(:league) { create :league }
  let!(:fpl_team1) { create :fpl_team, league: league, owner: user }
  let!(:fpl_team2) { create :fpl_team, league: league }

  describe 'GET /index' do
    before { api.authenticate(user) }

    it 'returns a list of the fpl_teams in the league' do
      api.get api_league_fpl_teams_path(league.id), params: { sort: { name: 'desc' } }

      expect(api.data).to match(
        [
          a_hash_including(
            'id' => fpl_team2.to_param,
            'name' => fpl_team2.name,
            'is_owner' => false,
            'owner' => a_hash_including(
              'id' => fpl_team2.owner.to_param,
              'email' => fpl_team2.owner.email,
              'username' => fpl_team2.owner.username,
            ),
          ),
          a_hash_including(
            'id' => fpl_team1.to_param,
            'name' => fpl_team1.name,
            'is_owner' => true,
            'owner' => a_hash_including(
              'id' => user.to_param,
              'email' => user.email,
              'username' => user.username,
            ),
          ),
        ],
      )
    end
  end
end
