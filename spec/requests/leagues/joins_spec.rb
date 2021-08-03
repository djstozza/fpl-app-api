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

RSpec.describe 'api/leagues/league_id/joins', type: :request do
  let!(:user) { create :user }
  let!(:league) { create :league }

  describe 'POST /create' do
    it 'creates a new fpl_team' do
      api.authenticate(user)

      expect do
        api.post api_leagues_join_url,
                 params: { league: { fpl_team_name: 'New fpl_team', code: league.code, name: league.name } }
      end
      .to change(FplTeam, :count).from(0).to(1)

      expect(api.data).to contain_exactly(
        a_hash_including(
          'id' => league.to_param,
          'name' => league.name,
          'status' => league.status.humanize,
          'is_owner' => false,
          'show_draft_pick_column' => false,
          'show_live_columns' => false,
          'owner' => a_hash_including('id' => league.owner.to_param),
        )
      )
    end

    it 'responds with a 422 message if params invalid' do
      create(:fpl_team, league: league, owner: user)

      api.authenticate(user)

      api.post api_leagues_join_url,
               params: { league: { fpl_team_name: 'New fpl_team', code: league.code, name: league.name } }

      expect(api.response).to have_http_status(:unprocessable_entity)

      expect(api.errors).to contain_exactly(
        a_hash_including('detail' => 'You have already joined this league', 'source' => 'base'),
      )
    end

    it 'responds with a 422 message if the name is invalid' do
      api.authenticate(user)

      api.post api_leagues_join_url,
               params: { league: { fpl_team_name: 'New fpl_team', code: league.code, name: 'invalid' } }

      expect(api.response).to have_http_status(:unprocessable_entity)

      expect(api.errors).to contain_exactly(
        a_hash_including('detail' => 'Name does not match with any league on record', 'source' => 'name'),
      )
    end
  end
end
