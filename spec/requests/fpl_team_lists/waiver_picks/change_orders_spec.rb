require 'rails_helper'

RSpec.describe 'fpl_team_lists/:fpl_team_list_id/waiver_picks/:waiver_pick_id/change_orders', :no_transaction, type: :request do
  let(:round) { create :round, :current }
  let(:fpl_team_list) { create :fpl_team_list, round: round }
  let!(:waiver_pick1) { create :waiver_pick, pick_number: 1, fpl_team_list: fpl_team_list }
  let!(:waiver_pick2) { create :waiver_pick, pick_number: 2, fpl_team_list: fpl_team_list }
  let!(:waiver_pick3) { create :waiver_pick, pick_number: 3, fpl_team_list: fpl_team_list }
  let!(:waiver_pick4) { create :waiver_pick, pick_number: 4, fpl_team_list: fpl_team_list }

  before { api.authenticate(fpl_team_list.owner) }

  describe 'POST /create' do
    it 'successfully changes the order' do
      expect {
        api.post api_fpl_team_list_waiver_pick_change_order_url(fpl_team_list, waiver_pick1),
                 params: { waiver_pick: { new_pick_number: 3 } }
      }
      .to change { waiver_pick1.reload.pick_number }.from(1).to(3)
      .and change { waiver_pick2.reload.pick_number }.from(2).to(1)
      .and change { waiver_pick3.reload.pick_number }.from(3).to(2)
      .and change { waiver_pick4.reload.updated_at }.by(0)


      expect(response).to have_http_status(:success)
      expect(api.data).to match(
        [
          a_hash_including(
            'id' => waiver_pick2.to_param,
            'out_player' => a_hash_including(
              'id' => waiver_pick2.out_player.to_param,
            ),
            'out_team' => a_hash_including(
              'id' => waiver_pick2.out_player.team.to_param,
            ),
            'in_player' => a_hash_including(
              'id' => waiver_pick2.in_player.to_param,
            ),
            'in_team' => a_hash_including(
              'id' => waiver_pick2.in_player.team.to_param,
            ),
            'status' => 'Pending',
            'pick_number' => 1,
            'position' => waiver_pick2.out_player.position.singular_name_short,
          ),
          a_hash_including(
            'id' => waiver_pick3.to_param,
            'out_player' => a_hash_including(
              'id' => waiver_pick3.out_player.to_param,
            ),
            'out_team' => a_hash_including(
              'id' => waiver_pick3.out_player.team.to_param,
            ),
            'in_player' => a_hash_including(
              'id' => waiver_pick3.in_player.to_param,
            ),
            'in_team' => a_hash_including(
              'id' => waiver_pick3.in_player.team.to_param,
            ),
            'status' => 'Pending',
            'pick_number' => 2,
            'position' => waiver_pick3.out_player.position.singular_name_short,
          ),
          a_hash_including(
            'id' => waiver_pick1.to_param,
            'out_player' => a_hash_including(
              'id' => waiver_pick1.out_player.to_param,
            ),
            'out_team' => a_hash_including(
              'id' => waiver_pick1.out_player.team.to_param,
            ),
            'in_player' => a_hash_including(
              'id' => waiver_pick1.in_player.to_param,
            ),
            'in_team' => a_hash_including(
              'id' => waiver_pick1.in_player.team.to_param,
            ),
            'status' => 'Pending',
            'pick_number' => 3,
            'position' => waiver_pick1.out_player.position.singular_name_short,
          ),
          a_hash_including(
            'id' => waiver_pick4.to_param,
            'out_player' => a_hash_including(
              'id' => waiver_pick4.out_player.to_param,
            ),
            'out_team' => a_hash_including(
              'id' => waiver_pick4.out_player.team.to_param,
            ),
            'in_player' => a_hash_including(
              'id' => waiver_pick4.in_player.to_param,
            ),
            'in_team' => a_hash_including(
              'id' => waiver_pick4.in_player.team.to_param,
            ),
            'status' => 'Pending',
            'pick_number' => 4,
            'position' => waiver_pick4.out_player.position.singular_name_short,
          ),
        ],
      )
    end

    it 'returns an error if invalid' do
      fpl_team_list.fpl_team.update(owner: create(:user))


        api.post api_fpl_team_list_waiver_pick_change_order_url(fpl_team_list, waiver_pick1),
                 params: { waiver_pick: { new_pick_number: 3 } }


      expect(response).to have_http_status(:unprocessable_entity)

      expect(api.errors).to contain_exactly(
        a_hash_including('detail' => 'You are not authorised to perform this action', 'source' => 'base'),
      )
    end
  end
end
