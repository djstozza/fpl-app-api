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

RSpec.describe '/api/teams', type: :request do
  let!(:team1) do
    create(
      :team,
      position: 2,
      points: 4,
      form: %w[W L D],
      goals_for: 3,
      goals_against: 3,
      goal_difference: 0,
      wins: 1,
      losses: 1,
      draws: 1,
      clean_sheets: 1,
    )
  end
  let!(:team2) { create(:team) }

  describe 'GET /index' do
    it 'renders a successful response' do
      api.get api_teams_url, params: { sort: { name: 'asc'} }

      expect(response).to be_successful

      expect(api.data).to contain_exactly(
        a_hash_including(
          'id' => team1.to_param,
          'name' => team1.name,
          'short_name' => team1.short_name,
        ),
        a_hash_including(
          'id' => team2.to_param,
          'name' => team2.name,
          'short_name' => team2.short_name,
        ),
      )
    end
  end

  describe 'GET /show', :no_transaction do
    include_examples 'not found', 'team'

    let(:team3) { build :team }

    let!(:fixture1) do
      create(
        :fixture,
        home_team: team1,
        away_team: team2,
        team_h_score: 3,
        team_a_score: 1,
      )
    end

    let!(:fixture2) do
      create(
        :fixture,
        home_team: team3,
        away_team: team1,
        team_h_score: 2,
        team_a_score: 0
      )
    end

    let!(:fixture3) do
      create(
        :fixture,
        home_team: team1,
        away_team: team2,
        team_h_score: 0,
        team_a_score: 0
      )
    end

    let!(:player1) { create :player, :forward, team: team1 }
    let!(:player2) { create :player, :midfielder, team: team1 }

    it 'renders a successful response' do
      api.get api_team_url(team1)
      expect(response).to be_successful

      expect(api.data).to include(
        'id' => team1.to_param,
        'name' => team1.name,
        'position' => 2,
        'points' => 4,
        'form' => %w[W L D],
        'wins' => 1,
        'losses' => 1,
        'draws' => 1,
        'clean_sheets' => 1,
        'goals_for' => 3,
        'goals_against' => 3,
        'goal_difference' => 0,
        'fixtures' => containing_exactly(
          a_hash_including(
            'round' => a_hash_including(
              'id' => fixture1.round.to_param,
              'name' => fixture1.round.name
            ),
            'home_team_score' => 3,
            'away_team_score' => 1,
            'opponent' => a_hash_including(
              'id' => team2.to_param,
              'short_name' => team2.short_name,
            ),
            'result' => 'W',
          ),
          a_hash_including(
            'round' => a_hash_including(
              'id' => fixture2.round.to_param,
              'name' => fixture2.round.name
            ),
            'home_team_score' => 2,
            'away_team_score' => 0,
            'opponent' => a_hash_including(
              'id' => team3.to_param,
              'short_name' => team3.short_name,
            ),
            'result' => 'L',
          ),
          a_hash_including(
            'round' => a_hash_including(
              'id' => fixture3.round.to_param,
              'name' => fixture3.round.name
            ),
            'home_team_score' => 0,
            'away_team_score' => 0,
            'opponent' => a_hash_including(
              'id' => team2.to_param,
              'short_name' => team2.short_name,
            ),
            'result' => 'D',
          ),
        ),
        'players' => containing_exactly(
          a_hash_including(
            'id' => player1.to_param,
            'first_name' => player1.first_name,
            'last_name' => player1.last_name,
            'position' => 'FWD',
          ),
          a_hash_including(
            'id' => player2.to_param,
            'first_name' => player2.first_name,
            'last_name' => player2.last_name,
            'position' => 'MID',
          ),
        ),
      )
    end

    it 'caches against the request' do
      api.get api_team_url(team1)
      expect(response).to have_http_status(200)

      etag = api.response.headers['ETag']
      last_modified = api.response.headers['Last-Modified']

      get_request_with_caching(team1, etag, last_modified)
      expect(api.response).to have_http_status(304)

      etag = api.response.headers['ETag']
      last_modified = api.response.headers['Last-Modified']

      team1.update!(updated_at: 10.minutes.from_now)

      get_request_with_caching(team1, etag, last_modified)
      expect(api.response).to have_http_status(200)

      etag = api.response.headers['ETag']
      last_modified = api.response.headers['Last-Modified']

      fixture1.update!(updated_at: 20.minutes.from_now)

      get_request_with_caching(team1, etag, last_modified)
      expect(api.response).to have_http_status(200)
    end
  end

  private

  def get_request_with_caching(team, etag, last_modified)
    api.get api_team_url(team), headers: { 'HTTP_IF_NONE_MATCH' => etag, 'HTTP_IF_MODIFIED_SINCE' => last_modified }
  end
end
