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
end
