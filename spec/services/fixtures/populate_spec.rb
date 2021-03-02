require 'rails_helper'

RSpec.describe Fixtures::Populate, type: :service do
  include StubRequestHelper

  describe '#call' do
    before do
      stub_bootstrap_static_request

      Rounds::Populate.call
      Teams::Populate.call

      stub_fixture_request
    end

    it 'creates fixtures' do
      expect { described_class.call }.to change { Fixture.count }.from(0).to(18)

      fixture = Fixture.first

      expect(fixture.attributes).to include(
        'external_id' => 2,
        "team_h_difficulty" => 3,
        "team_a_difficulty" => 2,
        "minutes"=>90,
        "started"=>true,
        "finished"=>true,
        "stats"=> including(
          {
            "identifier"=>"goals_scored",
            "a"=>[{ "value"=>1, "element"=>4 }, { "value"=>1, "element"=>6 }, { "value"=>1, "element"=>494 }],
            "h"=>[],
          }
        )
      )

      expect(fixture.round.attributes).to include(
        'external_id' => 1,
        'name' => 'Gameweek 1',
      )

      expect(fixture.home_team.attributes).to include(
        'external_id' => 8,
        'name' => 'Fulham'
      )

      expect(fixture.away_team.attributes).to include(
        'external_id' => 1,
        'name' => 'Arsenal',
      )
    end

    it 'updates existing fixtures' do
      round = build(:round, external_id: 10)
      fixture = build(:fixture, round: round, external_id: 2)
      fixture.save

      expect { described_class.call }
        .to change { fixture.reload.round.external_id }.from(10).to(1)
    end
  end
end
