require 'rails_helper'

RSpec.describe 'list_positions/:list_position_id/waiver_picks', :no_transaction, type: :request do
  let(:round) { create :round, :current }
  let(:fpl_team_list) { create :fpl_team_list, round: round }

  before { api.authenticate(fpl_team_list.owner) }

  describe 'POST /create' do
    let(:position) { create :position, :forward }
    let(:player1) { create :player, position: position }
    let(:player2) { create :player, position: position }
    let!(:list_position) { create :list_position, fpl_team_list: fpl_team_list, player: player1 }

    it 'creates a new waiver_pick' do
      expect do
        api.post api_list_position_waiver_picks_url(list_position),
                 params: {
                   waiver_pick: {
                     in_player_id: player2.id,
                   },
                 }
      end
      .to change { fpl_team_list.waiver_picks.count }.from(0).to(1)

      expect(response).to have_http_status(:success)

      expect(api.data).to contain_exactly(
        a_hash_including(
          'id' => fpl_team_list.waiver_picks.first.to_param,
          'out_player' => a_hash_including(
            'id' => player1.to_param,
          ),
          'out_team' => a_hash_including(
            'id' => player1.team.to_param,
          ),
          'in_player' => a_hash_including(
            'id' => player2.to_param,
          ),
          'in_team' => a_hash_including(
            'id' => player2.team.to_param,
          ),
          'status' => 'Pending',
          'position' => position.singular_name_short,
        ),
      )
    end

    it 'returns an error if invalid' do
      fpl_team_list.fpl_team.update(owner: create(:user))

      expect do
        api.post api_list_position_waiver_picks_url(list_position),
                 params: {
                   waiver_pick: {
                     in_player_id: player2.id,
                   },
                 }
      end
      .not_to change(WaiverPick, :count)

      expect(response).to have_http_status(:unprocessable_entity)

      expect(api.errors).to contain_exactly(
        a_hash_including('detail' => 'You are not authorised to perform this action', 'source' => 'base'),
      )
    end
  end
end
