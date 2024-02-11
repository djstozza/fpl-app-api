require 'rails_helper'

RSpec.describe '/api/teams/:team_id/fixtures', :no_transaction, type: :request do
  let!(:team1) { create :team }
  let!(:team2) { create :team }
  let!(:fixture1) do
    create(
      :fixture,
      home_team: team1,
      away_team: team2,
      team_h_score: 1,
      team_a_score: 2,
      kickoff_time: 3.weeks.ago,
    )
  end

  let!(:fixture2) { create :fixture, away_team: team1, team_h_score: 0, team_a_score: 3, kickoff_time: 2.weeks.ago }

  let!(:fixture3) do
    create(
      :fixture,
      home_team: team1,
      away_team: team2,
      team_h_score: 2,
      team_a_score: 2,
      kickoff_time: 1.week.ago,
    )
  end

  it 'renders a sortable list of fixtures for the team' do
    api.get api_team_fixtures_url(team_id: team1.id), params: { sort: { result: 'asc' } }
    expect(api.data).to match(
      [
        a_hash_including(
          'id' => fixture3.to_param,
          'round' => { 'id' => fixture3.round.to_param, 'name' => fixture3.round.name },
          'opponent' => { 'id' => team2.to_param, 'short_name' => team2.short_name },
          'leg' => 'H',
          'result' => 'D',
        ),
        a_hash_including(
          'id' => fixture1.to_param,
          'round' => { 'id' => fixture1.round.to_param, 'name' => fixture1.round.name },
          'opponent' => { 'id' => team2.to_param, 'short_name' => team2.short_name },
          'leg' => 'H',
          'result' => 'L',
        ),
        a_hash_including(
          'id' => fixture2.to_param,
          'round' => { 'id' => fixture2.round.to_param, 'name' => fixture2.round.name },
          'opponent' => { 'id' => fixture2.home_team.to_param, 'short_name' => fixture2.home_team.short_name },
          'leg' => 'A',
          'result' => 'W',
        ),
      ],
    )

    api.get api_team_fixtures_url(team_id: team1.id), params: { sort: { kickoff_time: 'asc' } }

    expect(api.data).to match(
      [
        a_hash_including('id' => fixture1.to_param),
        a_hash_including('id' => fixture2.to_param),
        a_hash_including('id' => fixture3.to_param),
      ],
    )

    api.get api_team_fixtures_url(team_id: team1.id), params: { sort: { 'opposition_team.short_name' => 'desc' } }

    expect(api.data).to match(
      [
        a_hash_including('id' => fixture2.to_param),
        a_hash_including('id' => fixture1.to_param),
        a_hash_including('id' => fixture3.to_param),
      ],
    )
  end

  it 'caches against the request' do
    api.get api_team_fixtures_url(team_id: team1.id), params: { sort: { result: 'asc' } }
    expect(response).to have_http_status(:success)

    etag = api.response.headers['ETag']
    last_modified = api.response.headers['Last-Modified']

    get_request_with_caching(etag, last_modified)
    expect(api.response).to have_http_status(:not_modified)

    etag = api.response.headers['ETag']
    last_modified = api.response.headers['Last-Modified']

    team2.update!(updated_at: 10.minutes.from_now)

    get_request_with_caching(etag, last_modified)
    expect(api.response).to have_http_status(:success)
  end

  private

  def get_request_with_caching(etag, last_modified)
    api.get(
      api_team_fixtures_url(team_id: team1.id),
      params: { sort: { result: 'asc' } },
      headers: { 'HTTP_IF_NONE_MATCH' => etag, 'HTTP_IF_MODIFIED_SINCE' => last_modified },
    )
  end
end
