require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to test the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator. If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails. There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.

RSpec.describe 'fpl_team_lists/:fpl_team_list_id/waiver_picks', :no_transaction, type: :request do
  let(:round) { create :round, :current }
  let(:fpl_team_list) { create :fpl_team_list, round: round }

  before { api.authenticate(fpl_team_list.owner) }

  describe 'GET /index' do
    let!(:waiver_pick1) { create :waiver_pick, fpl_team_list: fpl_team_list, pick_number: 3 }
    let!(:waiver_pick2) { create :waiver_pick, :approved, fpl_team_list: fpl_team_list, pick_number: 1 }
    let!(:waiver_pick3) { create :waiver_pick, :declined, fpl_team_list: fpl_team_list, pick_number: 2 }

    it 'renders a successful response' do
      api.get api_fpl_team_list_waiver_picks_url(fpl_team_list)

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
            'status' => 'Approved',
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
            'status' => 'Declined',
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
        ],
      )
    end

    it 'returns nothing if the user is not the owner' do
      fpl_team_list.fpl_team.update(owner: create(:user))

      api.get api_fpl_team_list_waiver_picks_url(fpl_team_list)

      expect(response).to have_http_status(:success)
      expect(api.data).to be_empty
    end
  end

  describe 'DELETE /destroy' do
    let!(:waiver_pick1) { create :waiver_pick, pick_number: 1, fpl_team_list: fpl_team_list }
    let!(:waiver_pick2) { create :waiver_pick, pick_number: 2, fpl_team_list: fpl_team_list }
    let!(:waiver_pick3) { create :waiver_pick, pick_number: 3, fpl_team_list: fpl_team_list }
    let!(:waiver_pick4) { create :waiver_pick, pick_number: 4, fpl_team_list: fpl_team_list }

    it 'destroys the waiver pick and updates the waiver pick order' do
      expect { api.delete api_fpl_team_list_waiver_pick_url(fpl_team_list, waiver_pick1) }
        .to change(WaiverPick, :count).from(4).to(3)
        .and change { waiver_pick2.reload.pick_number }.from(2).to(1)
        .and change { waiver_pick3.reload.pick_number }.from(3).to(2)
        .and change { waiver_pick4.reload.pick_number }.from(4).to(3)

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
            'pick_number' => 3,
            'position' => waiver_pick4.out_player.position.singular_name_short,
          ),
        ],
      )
    end

    it 'returns an error if invalid' do
      fpl_team_list.fpl_team.update(owner: create(:user))

      expect { api.delete api_fpl_team_list_waiver_pick_url(fpl_team_list, waiver_pick1) }
        .to not_change { WaiverPick.count }
        .and not_change { waiver_pick1.reload.updated_at }
        .and not_change { waiver_pick2.reload.updated_at }
        .and not_change { waiver_pick3.reload.updated_at }
        .and not_change { waiver_pick4.reload.updated_at }

      expect(response).to have_http_status(:unprocessable_entity)

      expect(api.errors).to contain_exactly(
        a_hash_including('detail' => 'You are not authorised to perform this action', 'source' => 'base'),
      )
    end
  end
end
