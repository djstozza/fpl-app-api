require 'rails_helper'

RSpec.describe Leagues::Activate, type: :service do
  let!(:round) { create :round }
  let!(:league) { create :league, status: 'draft' }
  let!(:draft_pick1) { create :draft_pick, league: league, fpl_team: create(:fpl_team, league: league) }
  let!(:draft_pick2) { create :draft_pick, :mini_draft, league: league, fpl_team: create(:fpl_team, league: league) }
  subject(:service) { described_class.call(league) }

  it 'activates the league' do
    expect(FplTeams::ProcessInitialLineup).to receive(:call).twice.and_return(double(errors: []))
    expect { service }.to change { league.reload.status }.from('draft').to('live')
  end

  it 'does not activate the league the league is not in draft' do
    league.update(status: 'initialized')

    expect(FplTeams::ProcessInitialLineup).not_to receive(:call)

    expect { service }.not_to change { league.reload.status }
    expect(service.errors.full_messages).to contain_exactly('League cannot be activated at this time')
  end

  it 'does not activate the league if the draft has not been completed' do
    create(:draft_pick, :initialized, league: league, fpl_team: create(:fpl_team, league: league))

    expect(FplTeams::ProcessInitialLineup).not_to receive(:call)

    expect { service }.not_to change { league.reload.status }
    expect(service.errors.full_messages).to contain_exactly('The draft has not been completed yet')
  end
end
