require 'rails_helper'

RSpec.describe(
  'fpl_team_lists/:fpl_team_list_id/list_positions/:list_position_id/mini_draft_picks',
  :no_transaction,
  type: :request
) do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create :user }
  let(:round) { create :round, :mini_draft }
  let(:league) { create :league }
  let!(:fpl_team1) { create :fpl_team, league: league, mini_draft_pick_number: 1, rank: 3, owner: user }
  let!(:fpl_team2) { create :fpl_team, league: league, mini_draft_pick_number: 2, rank: 1 }
  let!(:fpl_team3) { create :fpl_team, league: league, mini_draft_pick_number: 3, rank: 2 }

  let(:fpl_team_list) { create :fpl_team_list, fpl_team: fpl_team1, round: round }

  let(:position) { create :position }
  let(:player1) { create :player, position: position }
  let(:player2) { create :player, position: position }

  let!(:list_position) { create :list_position, player: player1, fpl_team_list: fpl_team_list }

  before { fpl_team1.players << player1 }

  shared_examples 'create mini_draft_picks' do |season|
    it 'creates a mini_draft_pick, transfers the player and updates the next fpl_team' do
      travel_to round.deadline_time_as_time - 3.days do
        api.authenticate user

        expect do
          api.post api_fpl_team_list_list_position_mini_draft_picks_url(fpl_team_list, list_position),
                   params: { mini_draft_pick: { in_player_id: player2.id } }
        end
        .to change(MiniDraftPick, :count).from(0).to(1)
        .and change { list_position.reload.player }.from(player1).to(player2)
        .and change { fpl_team1.reload.players }.from([player1]).to([player2])

        expect(MiniDraftPick.first).to have_attributes(
          pick_number: 1,
          out_player: player1,
          in_player: player2,
          passed: false,
          fpl_team: fpl_team1,
          season: season,
        )

        expect(api.response).to have_http_status(:success)
        expect(api.data).to match(
          {
            'round' => a_hash_including(
              'id' => round.to_param,
            ),
            'can_make_mini_draft_pick' => false,
            'mini_draft_finished' => false,
            'season' => season,
            'fpl_team_list_id' => fpl_team_list.to_param,
          },
        )
      end
    end

    it 'returns a 422 message if invalid' do
      fpl_team1.update(owner: create(:user))

      travel_to round.deadline_time_as_time - 3.days do
        api.authenticate user

        expect do
          api.post api_fpl_team_list_list_position_mini_draft_picks_url(fpl_team_list, list_position),
                   params: { mini_draft_pick: { in_player_id: player2.id } }
        end
        .not_to change(MiniDraftPick, :count)

        expect(api.response).to have_http_status(:unprocessable_entity)

        expect(api.errors).to contain_exactly(
          a_hash_including('detail' => 'You are not authorised to perform this action', 'source' => 'base'),
        )
      end
    end
  end

  context 'when summer mini draft' do
    before { round.update(deadline_time: Round.summer_mini_draft_deadline + 1.week) }

    include_examples 'create mini_draft_picks', 'summer'
  end

  context 'when winter mini draft' do
    before { round.update(deadline_time: Round.winter_mini_draft_deadline + 1.week) }

    include_examples 'create mini_draft_picks', 'winter'
  end
end
