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

RSpec.describe 'fpl_team_lists/:fpl_team_list_id/trades', :no_transaction, type: :request do
  let(:fpl_team_list) { create :fpl_team_list }
  let!(:trade1) { create :trade, fpl_team_list: fpl_team_list }
  let!(:trade2) { create :trade, fpl_team_list: fpl_team_list }

  before { api.authenticate fpl_team_list.owner }

  describe 'GET /index' do
    it 'renders a successful response' do
      api.get api_fpl_team_list_trades_url(fpl_team_list)

      expect(response).to have_http_status(:success)

      expect(api.data).to match(
        [
          a_hash_including(
            'out_player' => a_hash_including(
              'id' => trade1.out_player.to_param,
              'first_name' => trade1.out_player.first_name,
              'last_name' => trade1.out_player.last_name,
            ),
            'in_player' => a_hash_including(
              'id' => trade1.in_player.to_param,
              'first_name' => trade1.in_player.first_name,
              'last_name' => trade1.in_player.last_name,
            ),
            'out_team' => a_hash_including(
              'id' => trade1.out_player.team.to_param,
              'short_name' => trade1.out_player.team.short_name,
            ),
            'in_team' => a_hash_including(
              'id' => trade1.in_player.team.to_param,
              'short_name' => trade1.in_player.team.short_name,
            ),
            'position' => trade1.out_player.position.singular_name_short,
          ),
          a_hash_including(
            'out_player' => a_hash_including(
              'id' => trade2.out_player.to_param,
              'first_name' => trade2.out_player.first_name,
              'last_name' => trade2.out_player.last_name,
            ),
            'in_player' => a_hash_including(
              'id' => trade2.in_player.to_param,
              'first_name' => trade2.in_player.first_name,
              'last_name' => trade2.in_player.last_name,
            ),
            'out_team' => a_hash_including(
              'id' => trade2.out_player.team.to_param,
              'short_name' => trade2.out_player.team.short_name,
            ),
            'in_team' => a_hash_including(
              'id' => trade2.in_player.team.to_param,
              'short_name' => trade2.in_player.team.short_name,
            ),
            'position' => trade2.out_player.position.singular_name_short,
          ),
        ],
      )
    end

    it 'returns nothing if the user is not the owner' do
      fpl_team_list.fpl_team.update(owner: create(:user))

      api.get api_fpl_team_list_trades_url(fpl_team_list)

      expect(response).to have_http_status(:success)
      expect(api.data).to be_empty
    end
  end
end
