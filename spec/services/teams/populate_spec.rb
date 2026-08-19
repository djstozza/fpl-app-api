require 'rails_helper'

RSpec.describe Teams::Populate, type: :service do
  include StubRequestHelper

  describe '#call' do
    before { stub_bootstrap_static_request }

    it 'creates teams' do
      expect { described_class.call }.to change(Team, :count).from(0).to(20)

      expect(Team.first.attributes).to include(
        'external_id' => 1,
        'name' => 'Arsenal',
        'code' => 3,
        'short_name' => 'ARS',
        'strength' => 4,
        'strength_overall_home' => 1190,
        'strength_overall_away' => 1210,
        'strength_attack_home' => 1170,
        'strength_attack_away' => 1210,
        'strength_defence_home' => 1190,
        'strength_defence_away' => 1200,
      )
    end

    it 'updates existing teams' do
      team = build(:team, name: 'Scunthorpe United', external_id: 1)
      team.save

      expect { described_class.call }
        .to change { team.reload.name }.from('Scunthorpe United').to('Arsenal')
    end

    it 'retries when rate limited by the FPL API' do
      stub_request(:get, 'https://fantasy.premierleague.com/api/bootstrap-static/')
        .to_return(
          { status: 429, headers: { 'Retry-After' => '0' } },
          {
            status: 200,
            body: file_fixture('bootstrap_static.json').read,
            headers: { 'Content-Type' => 'application/json' },
          },
        )

      expect { described_class.call }.to change(Team, :count).from(0).to(20)
    end
  end
end
