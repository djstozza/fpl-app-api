require 'rails_helper'

RSpec.describe 'api/leagues/league_id/draft_picks/facets', :no_transaction, type: :request do
  let(:user) { create :user }
  let(:league) { create :league }
  let!(:draft_pick1) { create :draft_pick, league: league, fpl_team: create(:fpl_team, league: league) }
  let!(:draft_pick2) { create :draft_pick, :mini_draft, league: league, fpl_team: create(:fpl_team, league: league) }
  let!(:draft_pick3) { create :draft_pick, :initialized, league: league, fpl_team: create(:fpl_team, league: league) }

  it 'returns a list of legue draft pick facets' do
    api.authenticate(user)

    api.get api_league_draft_picks_facets_url(league)

    expect(api.data).to include(
      'positions' => containing_exactly(
        a_hash_including(
          'label' => draft_pick1.player.position.singular_name_short,
          'value' => draft_pick1.player.position.to_param,
        ),
      ),
      'teams' => containing_exactly(
        a_hash_including(
          'label' => draft_pick1.player.team.short_name,
          'value' => draft_pick1.player.team.to_param,
        ),
      ),
      'fpl_teams' => containing_exactly(
        a_hash_including(
          'label' => draft_pick1.fpl_team.name,
          'value' => draft_pick1.fpl_team.to_param,
        ),
        a_hash_including(
          'label' => draft_pick2.fpl_team.name,
          'value' => draft_pick2.fpl_team.to_param,
        ),
        a_hash_including(
          'label' => draft_pick3.fpl_team.name,
          'value' => draft_pick3.fpl_team.to_param,
        ),
      ),
      'mini_draft' => containing_exactly(
        a_hash_including(
          'label' => 'Yes',
          'value' => true,
        ),
        a_hash_including(
          'label' => 'No',
          'value' => false,
        ),
      ),
    )
  end
end
