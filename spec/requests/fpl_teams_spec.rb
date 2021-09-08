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

RSpec.describe 'api/fpl_teams', type: :request do
  let!(:round) { create :round, :current }
  let!(:user) { create :user }
  let(:fpl_team) { create :fpl_team, owner: user }

  describe 'GET /index' do
    it 'returns a list of the fpl_teams where the user is the owner' do
      fpl_team.save

      create :fpl_team

      api.authenticate(user)
      api.get api_fpl_teams_url

      expect(api.data).to match(
        a_hash_including(
          'id' => fpl_team.to_param,
          'name' => fpl_team.name,
          'league' => a_hash_including('id' => fpl_team.league.to_param),
          'draft_pick_number' => fpl_team.draft_pick_number,
          'mini_draft_pick_number' => fpl_team.mini_draft_pick_number,
          'rank' => fpl_team.rank,
        ),
      )
    end
  end

  describe 'GET /show' do
    it 'renders a successful response with is_owner = true if the user is the owner' do
      api.authenticate(user)

      api.get api_fpl_team_url(fpl_team)

      expect(api.data).to match(
        'id' => fpl_team.to_param,
        'name' => fpl_team.name,
        'league' => a_hash_including('id' => fpl_team.league.to_param),
        'is_owner' => true,
        'owner' => a_hash_including('id' => user.to_param),
        'draft_pick_number' => fpl_team.draft_pick_number,
        'mini_draft_pick_number' => fpl_team.mini_draft_pick_number,
        'rank' => fpl_team.rank,
      )
    end

    it 'renders a successful response with is_owner = false if the user is not the owner' do
      another_user = create(:user)
      api.authenticate(another_user)

      api.get api_fpl_team_url(fpl_team)

      expect(api.data).to match(
        'id' => fpl_team.to_param,
        'name' => fpl_team.name,
        'league' => a_hash_including('id' => fpl_team.league.to_param),
        'is_owner' => false,
        'owner' => a_hash_including('id' => user.to_param),
        'draft_pick_number' => fpl_team.draft_pick_number,
        'mini_draft_pick_number' => fpl_team.mini_draft_pick_number,
        'rank' => fpl_team.rank,
      )
    end
  end

  describe 'PUT /update' do
    it 'updates the fpl_team' do
      api.authenticate(user)

      api.put api_fpl_team_url(fpl_team), params: { fpl_team: { name: 'New name', code: '12345678' } }

      expect(api.response).to have_http_status(:success)
      expect(api.data).to match(
        'id' => fpl_team.to_param,
        'name' => 'New name',
        'league' => a_hash_including('id' => fpl_team.league.to_param),
        'is_owner' => true,
        'owner' => a_hash_including('id' => user.to_param),
        'draft_pick_number' => fpl_team.draft_pick_number,
        'mini_draft_pick_number' => fpl_team.mini_draft_pick_number,
        'rank' => fpl_team.rank,
      )
    end

    it 'responds with a 422 message if params invalid' do
      api.authenticate(user)

      api.put api_fpl_team_url(fpl_team), params: { fpl_team: { name: nil } }

      expect(api.response).to have_http_status(:unprocessable_entity)

      expect(api.errors).to include(
        a_hash_including('detail' => "Name can't be blank", 'source' => 'name'),
      )
    end

    it 'responds with a 422 message if the user is not the owner' do
      another_user = create :user
      api.authenticate(another_user)

      api.put api_fpl_team_url(fpl_team), params: { fpl_team: { name: 'New name' } }

      expect(api.response).to have_http_status(:unprocessable_entity)
      expect(api.errors).to include(
        a_hash_including('detail' => 'You are not authorised to perform this action', 'source' => 'base'),
      )
    end
  end
end
