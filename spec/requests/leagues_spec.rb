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

RSpec.describe 'api/leagues', type: :request do
  let!(:user) { create :user }
  let(:league) { create :league, owner: user }

  describe 'GET /index' do
    it 'returns a list of the leagues where the user is the owner' do
      league.save

      create :league

      api.authenticate(user)
      api.get api_leagues_url


      expect(api.data).to contain_exactly(
        'id' => league.to_param,
        'name' => league.name,
        'status' => league.status,
      )
    end
  end

  describe 'GET /show' do
    it 'renders a successful response with is_owner = true if the user is the owner' do
      api.authenticate(user)

      api.get api_league_url(league)

      expect(api.data).to match(
        'id' => league.to_param,
        'name' => league.name,
        'status' => league.status,
        'is_owner' => true,
        'owner' => a_hash_including('id' => user.to_param),
        'fpl_teams' => [],
      )
    end

    it 'renders a successful response with is_owner = false if the user is not the owner' do
      another_user = create(:user)
      api.authenticate(another_user)

      api.get api_league_url(league)

      expect(api.data).to match(
        'id' => league.to_param,
        'name' => league.name,
        'status' => league.status,
        'is_owner' => false,
        'owner' => a_hash_including('id' => user.to_param),
        'fpl_teams' => [],
      )
    end
  end

  describe 'POST /create' do
    it 'creates a new league' do
      api.authenticate(user)

      api.post api_leagues_url,
               params: { league: { name: 'New league', code: '12345678', fpl_team_name: 'New fpl_team' } }

      new_league = League.last

      expect(api.data).to match(
        'id' => new_league.to_param,
        'name' => 'New league',
        'status' => new_league.status,
        'is_owner' => true,
        'owner' => a_hash_including('id' => user.to_param),
        'fpl_teams' => containing_exactly(
          a_hash_including('name' => 'New fpl_team')
        )
      )
    end

    it 'responds with a 422 message if params invalid' do
      api.authenticate(user)

      api.post api_leagues_url, params: { league: { name: nil, code: nil, fpl_team_name: nil } }

      expect(api.response).to have_http_status(:unprocessable_entity)

      expect(api.errors).to contain_exactly(
        a_hash_including('detail' => "Name can't be blank", 'source' => 'name'),
        a_hash_including('detail' => "Code can't be blank", 'source' => 'code'),
        a_hash_including('detail' => "Fpl team name can't be blank", 'source' => 'fpl_team_name'),
      )
    end
  end

  describe 'PUT /update' do
    it 'updates the league' do
      api.authenticate(user)

      api.put api_league_url(league), params: { league: { name: 'New name', code: '12345678' } }

      expect(api.response).to have_http_status(:success)
      expect(api.data).to match(
        'id' => league.to_param,
        'name' => 'New name',
        'status' => league.status,
        'is_owner' => true,
        'owner' => a_hash_including('id' => user.to_param),
        'fpl_teams' => [],
      )

      expect(league.reload.code).to eq('12345678')
    end

    it 'responds with a 422 message if params invalid' do
      api.authenticate(user)

      api.put api_league_url(league), params: { league: { name: nil, code: nil } }

      expect(api.response).to have_http_status(:unprocessable_entity)

      expect(api.errors).to contain_exactly(
        a_hash_including('detail' => "Name can't be blank", 'source' => 'name'),
        a_hash_including('detail' => "Code can't be blank", 'source' => 'code'),
      )
    end

    it 'renders a 401 message if the user is not the owner' do
      another_user = create :user
      api.authenticate(another_user)

      api.put api_league_url(league), params: { league: { name: 'New league', code: '12345678' } }

      expect(api.response).to have_http_status(:unauthorized)
    end
  end
end
