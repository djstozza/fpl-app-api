require 'rails_helper'

RSpec.describe 'api/leagues/league_id/mini_draft_picks/facets', :no_transaction, type: :request do
  let(:league) { create :league }
  let(:fpl_team1) { create :fpl_team, league: league }
  let(:fpl_team2) { create :fpl_team, league: league }
  let!(:mini_draft_pick1) { create :mini_draft_pick, fpl_team: fpl_team1 }
  let!(:mini_draft_pick2) { create :mini_draft_pick, :passed, fpl_team: fpl_team2 }
  let!(:mini_draft_pick3) { create :mini_draft_pick, :passed, :winter, fpl_team: fpl_team1 }
  let!(:mini_draft_pick4) { create :mini_draft_pick, :winter, fpl_team: fpl_team2 }

  before { api.authenticate fpl_team1.owner }

  describe 'GET /index' do
    it 'renders a list of the mini draft_picks by season' do
      api.get api_league_mini_draft_picks_facets_url(league), params: { mini_draft_pick: { season: 'summer' } }

      expect(api.response).to have_http_status(:success)
      expect(api.data).to include(
        'out_teams' => contain_exactly(
          a_hash_including(
            'value' => mini_draft_pick1.out_player.team.to_param,
            'label' => mini_draft_pick1.out_player.team.short_name,
          ),
        ),
        'in_teams' => contain_exactly(
          a_hash_including(
            'value' => mini_draft_pick1.in_player.team.to_param,
            'label' => mini_draft_pick1.in_player.team.short_name,
          ),
        ),
        'fpl_teams' => containing_exactly(
          a_hash_including(
            'label' => fpl_team1.name,
            'value' => fpl_team1.to_param,
          ),
          a_hash_including(
            'label' => fpl_team2.name,
            'value' => fpl_team2.to_param,
          ),
        ),
        'positions' => contain_exactly(
          a_hash_including(
            'value' => mini_draft_pick1.out_player.position.to_param,
            'label' => mini_draft_pick1.out_player.position.singular_name_short,
          ),
        ),
        'passed' => contain_exactly(
          a_hash_including(
            'value' => false,
            'label' => 'No',
          ),
          a_hash_including(
            'value' => true,
            'label' => 'Yes',
          ),
        )
      )

      api.get api_league_mini_draft_picks_facets_url(league), params: { mini_draft_pick: { season: 'winter' } }

      expect(api.response).to have_http_status(:success)

      expect(api.data).to include(
        'out_teams' => contain_exactly(
          a_hash_including(
            'value' => mini_draft_pick4.out_player.team.to_param,
            'label' => mini_draft_pick4.out_player.team.short_name,
          ),
        ),
        'in_teams' => contain_exactly(
          a_hash_including(
            'value' => mini_draft_pick4.in_player.team.to_param,
            'label' => mini_draft_pick4.in_player.team.short_name,
          ),
        ),
        'fpl_teams' => containing_exactly(
          a_hash_including(
            'label' => fpl_team1.name,
            'value' => fpl_team1.to_param,
          ),
          a_hash_including(
            'label' => fpl_team2.name,
            'value' => fpl_team2.to_param,
          ),
        ),
        'positions' => contain_exactly(
          a_hash_including(
            'value' => mini_draft_pick4.out_player.position.to_param,
            'label' => mini_draft_pick4.out_player.position.singular_name_short,
          ),
        ),
        'passed' => contain_exactly(
          a_hash_including(
            'value' => false,
            'label' => 'No',
          ),
          a_hash_including(
            'value' => true,
            'label' => 'Yes',
          ),
        )
      )
    end
  end
end
