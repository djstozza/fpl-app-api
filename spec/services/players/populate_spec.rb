require 'rails_helper'

RSpec.describe Players::Populate, type: :service do
  include StubRequestHelper

  describe '#call' do
    before do
      stub_bootstrap_static_request

      Positions::Populate.call
      Teams::Populate.call
    end

    it 'creates players' do
      expect { described_class.call }.to change { Player.count }.from(0).to(11)

      player = Player.first
      expect(player.attributes).to include(
        'external_id' => 4,
        'first_name' => 'Pierre-Emerick',
        'last_name' => 'Aubameyang',
        'total_points' => 95,
      )
      expect(player.team.attributes).to include(
        'external_id' => 1,
        'name' => 'Arsenal',
      )

      expect(player.position.attributes).to include(
        'external_id' => 3,
        'singular_name' => 'Midfielder',
        'singular_name_short' => 'MID',
      )
    end

    it 'updates existing players' do
      player = build(:player, :midfielder, total_points: 0, team: Team.last,  external_id: 4)
      player.save

      expect { described_class.call }
        .to change { player.reload.team_id }.from(Team.last.id).to(Team.first.id)
        .and change { player.reload.total_points }.from(0).to(95)
    end
  end
end
