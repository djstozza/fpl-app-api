require 'rails_helper'

RSpec.describe(
  'fpl_team_lists/:fpl_team_list_id/inter_team_trade_groups/:inter_team_trade_group_id/cancel',
  :no_transaction,
  type: :request
) do
  let(:round) { create :round, :current }
  let(:fpl_team1) { create :fpl_team }
  let(:fpl_team2) { create :fpl_team, league: fpl_team1.league }
  let(:fpl_team_list1) { create :fpl_team_list, fpl_team: fpl_team1, round: round }
  let(:fpl_team_list2) { create :fpl_team_list, fpl_team: fpl_team2, round: round }

  let(:position) { create :position, :forward }
  let(:player1) { create :player, position: position }
  let(:player2) { create :player, position: position }

  let!(:list_position1) { create :list_position, player: player1, fpl_team_list: fpl_team_list1 }
  let!(:list_position2) { create :list_position, player: player2, fpl_team_list: fpl_team_list2 }

  let(:inter_team_trade_group) do
    create(
      :inter_team_trade_group,
      :submitted,
      out_fpl_team_list: fpl_team_list1,
      in_fpl_team_list: fpl_team_list2,
    )
  end

  let!(:inter_team_trade) do
    create(
      :inter_team_trade,
      inter_team_trade_group: inter_team_trade_group,
      out_player: player1,
      in_player: player2,
    )
  end

  before { api.authenticate(fpl_team_list1.owner) }

  describe 'POST /create' do
    it 'changes the status of the inter_team_trade_group to cancelled' do
      expect do
        api.post api_fpl_team_list_inter_team_trade_group_cancel_url(fpl_team_list1, inter_team_trade_group)
      end
      .to change { inter_team_trade_group.reload.status }.from('submitted').to('cancelled')

      expect(api.response).to have_http_status(:success)

      expect(api.data['in_trade_groups']).to be_empty
      expect(api.data['out_trade_groups']).to be_empty
    end

    it 'returns a 422 if there is an error' do
      fpl_team1.update(owner: create(:user))

      expect do
        api.post api_fpl_team_list_inter_team_trade_group_cancel_url(fpl_team_list1, inter_team_trade_group)
      end
      .to not_change { inter_team_trade_group.reload.updated_at }

      expect(response).to have_http_status(:unprocessable_entity)

      expect(api.errors).to contain_exactly(
        a_hash_including('detail' => 'You are not authorised to perform this action', 'source' => 'base'),
      )
    end
  end
end
