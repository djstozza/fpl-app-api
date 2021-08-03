require 'rails_helper'

RSpec.describe 'api/leagues/league_id/mini_draft_picks/status', :no_transaction, type: :request do
  include ActiveSupport::Testing::TimeHelpers
  let(:round) { create :round, :mini_draft }
  let(:league) { create :league }
  let!(:fpl_team1) { create :fpl_team, mini_draft_pick_number: 1, rank: 2, league: league }
  let!(:fpl_team2) { create :fpl_team, mini_draft_pick_number: 2, rank: 1, league: league }

  shared_examples 'status' do |season|
    it 'returns the status hash with can_make_mini_draft_pick = true and mini_draft_finished = false' do
      travel_to round.deadline_time_as_time - 3.days do
        api.authenticate fpl_team1.owner

        api.get api_league_mini_draft_picks_status_index_url(league)

        expect(api.response).to have_http_status(:success)
        expect(api.data).to match(
          {
            'round' => a_hash_including(
              'id' => round.to_param,
            ),
            'can_make_mini_draft_pick' => true,
            'mini_draft_finished' => false,
            'season' => season,
          },
        )
      end
    end

    it 'returns the status hash with can_make_mini_draft_pick = false and mini_draft_finished = true' do
      travel_to round.deadline_time_as_time - 3.days do
        api.authenticate fpl_team1.owner

        create :mini_draft_pick, :passed, pick_number: 1, season: season, fpl_team: fpl_team1
        create :mini_draft_pick, :passed, pick_number: 2, season: season, fpl_team: fpl_team2
        create :mini_draft_pick, :passed, pick_number: 3, season: season, fpl_team: fpl_team2
        create :mini_draft_pick, :passed, pick_number: 4, season: season, fpl_team: fpl_team1

        api.get api_league_mini_draft_picks_status_index_url(league)

        expect(api.response).to have_http_status(:success)

        expect(api.data).to match(
          {
            'round' => a_hash_including(
              'id' => round.to_param,
            ),
            'can_make_mini_draft_pick' => false,
            'mini_draft_finished' => true,
            'season' => season,
          },
        )
      end
    end
  end

  context 'when summer mini draft' do
    before { round.update(deadline_time: Round.summer_mini_draft_deadline + 1.week) }

    include_examples 'status', 'summer'
  end

  context 'when winter mini draft' do
    before { round.update(deadline_time: Round.winter_mini_draft_deadline + 1.week) }

    include_examples 'status', 'winter'
  end
end
