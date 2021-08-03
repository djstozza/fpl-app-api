require 'rails_helper'

RSpec.describe(
  'fpl_team_lists/:fpl_team_list_id/inter_team_trade_groups/:inter_team_trade_group_id/add_trades',
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
  let(:player3) { create :player, position: position }
  let(:player4) { create :player, position: position }

  let!(:list_position1) { create :list_position, player: player1, fpl_team_list: fpl_team_list1 }
  let!(:list_position2) { create :list_position, player: player2, fpl_team_list: fpl_team_list1 }
  let!(:list_position3) { create :list_position, player: player3, fpl_team_list: fpl_team_list2 }
  let!(:list_position4) { create :list_position, player: player4, fpl_team_list: fpl_team_list2 }

  let(:inter_team_trade_group) do
    create(
      :inter_team_trade_group,
      out_fpl_team_list: fpl_team_list1,
      in_fpl_team_list: fpl_team_list2,
    )
  end

  let!(:inter_team_trade) do
    create(
      :inter_team_trade,
      inter_team_trade_group: inter_team_trade_group,
      out_player: player1,
      in_player: player3,
    )
  end

  before { api.authenticate(fpl_team_list1.owner) }

  describe 'POST /create' do
    it 'adds a trade to the inter_team_trade_group' do
      expect do
        api.post api_fpl_team_list_inter_team_trade_group_add_trade_url(fpl_team_list1, inter_team_trade_group),
                 params: {
                   inter_team_trade_group: {
                     out_player_id: player2.id,
                     in_player_id: player4.id,
                   },
                 }
      end
      .to change(InterTeamTrade, :count).from(1).to(2)

      expect(api.response).to have_http_status(:success)

      expect(api.data['out_trade_groups']).to contain_exactly(
        a_hash_including(
          'id' => inter_team_trade_group.to_param,
          'status' => 'Pending',
          'trades' => include(
            a_hash_including(
              'id' => inter_team_trade.to_param,
              'in_team' => a_hash_including(
                'id' => player3.team.to_param,
                'short_name' => player3.team.short_name,
              ),
              'out_team' => a_hash_including(
                'id' => player1.team.to_param,
                'short_name' => player1.team.short_name,
              ),
              'position' => position.singular_name_short,
              'in_player' => a_hash_including(
                'id' => player3.to_param,
                'last_name' => player3.last_name,
                'first_name' => player3.first_name,
              ),
              'out_player' => a_hash_including(
                'id' => player1.to_param,
                'last_name' => player1.last_name,
                'first_name' => player1.first_name,
              ),
            ),
            a_hash_including(
              'in_team' => a_hash_including(
                'id' => player4.team.to_param,
                'short_name' => player4.team.short_name,
              ),
              'out_team' => a_hash_including(
                'id' => player2.team.to_param,
                'short_name' => player2.team.short_name,
              ),
              'position' => position.singular_name_short,
              'in_player' => a_hash_including(
                'id' => player4.to_param,
                'last_name' => player4.last_name,
                'first_name' => player4.first_name,
              ),
              'out_player' => a_hash_including(
                'id' => player2.to_param,
                'last_name' => player2.last_name,
                'first_name' => player2.first_name,
              ),
            ),
          ),
          'can_cancel' => true,
          'can_submit' => true,
          'can_approve' => false,
          'in_fpl_team' => a_hash_including(
            'id' => fpl_team2.to_param,
            'name' => fpl_team2.name,
          ),
          'out_fpl_team' => a_hash_including(
            'id' => fpl_team1.to_param,
            'name' => fpl_team1.name,
          ),
        ),
      )
      expect(api.data['in_trade_groups']).to be_empty
    end

    it 'returns a 422 if there is an error' do
      fpl_team1.update(owner: create(:user))

      expect do
        api.post api_fpl_team_list_inter_team_trade_group_add_trade_url(fpl_team_list1, inter_team_trade_group),
                 params: {
                   inter_team_trade_group: {
                     out_player_id: player2.id,
                     in_player_id: player4.id,
                   },
                 }
      end.to not_change { inter_team_trade_group.reload.updated_at }

      expect(response).to have_http_status(:unprocessable_entity)

      expect(api.errors).to contain_exactly(
        a_hash_including('detail' => 'You are not authorised to perform this action', 'source' => 'base'),
      )
    end
  end
end
