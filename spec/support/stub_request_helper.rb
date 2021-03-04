require 'httparty'

module StubRequestHelper
  module_function

  def stub_bootstrap_static_request
    stub_request(:get, 'https://fantasy.premierleague.com/api/bootstrap-static/')
      .and_return(
        status: 200,
        body: file_fixture('bootstrap_static.json').read,
        headers: { 'Content-Type'=> 'application/json' },
      )
  end

  def stub_fixture_request
    stub_request(:get, 'https://fantasy.premierleague.com/api/fixtures/')
      .and_return(
        status: 200,
        body: file_fixture('fixtures.json').read,
        headers: { 'Content-Type'=> 'application/json' },
      )
  end

  def stub_player_summary_request(external_id)
    stub_request(:get, "https://fantasy.premierleague.com/api/element-summary/#{external_id}/")
      .and_return(
        status: 200,
        body: file_fixture("element_summary_#{external_id}.json").read,
        headers: { 'Content-Type'=> 'application/json' },
      )
  end
end
