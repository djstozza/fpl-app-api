require 'rails_helper'

RSpec.describe Fixtures::Populate, type: :service do
  include StubRequestHelper

  before do
    stub_bootstrap_static_request

    Rounds::Populate.call
    Teams::Populate.call
  end


  describe '#call - all round fixtures' do
    before { stub_fixture_request }

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
  end

  describe '#call - single round' do
    let(:round_1) { Round.first }
    let(:round_2) { Round.second }
    let!(:fixture_1) { create :fixture, round: round_1, started: true, finished: true, external_id: 7 }
    let!(:fixture_2) { create :fixture, round: round_1, started: true, finished: false, external_id: 8 }
    let!(:fixture_3) { create :fixture, round: round_2, started: true, finished: false, external_id: 12 }


    it 'only updates existing fixtures of the specfied round that have not finished' do
      stub_round_fixture_request(round_1.external_id)

      expect { described_class.call(round_1) }
        .to change { fixture_2.reload.finished }.from(false).to(true)
        .and change { fixture_1.reload.updated_at }.by(0)
        .and change { fixture_3.reload.updated_at }.by(0)
    end
  end
end
