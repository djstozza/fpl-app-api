require 'rails_helper'

RSpec.describe 'list_positions/:list_position_id/trades', :no_transaction, type: :request do
  let(:round) { create :round, :current, deadline_time: 23.hours.from_now }
  let(:fpl_team) { create :fpl_team }
  let(:fpl_team_list) { create :fpl_team_list, fpl_team: fpl_team, round: round }
  let(:position) { create :position, :forward }
  let(:player1) { create :player, position: position }
  let(:list_position) { create :list_position, player: player1, fpl_team_list: fpl_team_list }
  let(:player2) { create :player, position: position }

  before do
    api.authenticate(fpl_team.owner)
    fpl_team.players << player1
  end

  describe 'POST /create' do
    it 'successfully processes the trade' do
      expect {
        api.post api_list_position_trades_url(list_position),
                 params: { trade: { in_player_id: player2.id } }
      }
      .to change { Trade.count }.from(0).to(1)
      .and change { list_position.reload.player }.from(player1).to(player2)
      .and change { fpl_team.reload.players }.from([player1]).to([player2])
      .and change { fpl_team.league.reload.players }.from([player1]).to([player2])

      expect(api.response).to have_http_status(:success)

      expect(api.data).to contain_exactly(
        a_hash_including(
          'out_player' => a_hash_including(
            'id' => player1.to_param,
            'first_name' => player1.first_name,
            'last_name' => player1.last_name,
          ),
          'in_player' => a_hash_including(
            'id' => player2.to_param,
            'first_name' => player2.first_name,
            'last_name' => player2.last_name,
          ),
          'out_team' => a_hash_including(
            'id' => player1.team.to_param,
            'short_name' => player1.team.short_name,
          ),
          'in_team' => a_hash_including(
            'id' => player2.team.to_param,
            'short_name' => player2.team.short_name,
          ),
          'position' => player1.position.singular_name_short,
        ),
      )
    end

    it 'returns an error if invalid' do
      fpl_team_list.fpl_team.update(owner: create(:user))

      expect {
        api.post api_list_position_trades_url(list_position),
                 params: { trade: { in_player_id: player2.id } }
      }
      .to change { Trade.count }.by(0)
      .and change { list_position.reload.updated_at }.by(0)

      expect(response).to have_http_status(:unprocessable_entity)

      expect(api.errors).to contain_exactly(
        a_hash_including('detail' => 'You are not authorised to perform this action', 'source' => 'base'),
      )
    end
  end
end
