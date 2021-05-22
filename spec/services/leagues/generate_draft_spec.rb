require 'rails_helper'

RSpec.describe Leagues::GenerateDraft, type: :service do
  subject(:service) { described_class.call(league, user) }
  let(:user) { create :user }
  let(:league) { create :league, owner: user }
  let!(:fpl_team) { create :fpl_team, league: league, owner: user }

  before do
    (League::MIN_FPL_TEAM_QUOTA - 1).times do
      create(:fpl_team, league: league)
    end
  end

  it 'creates draft_pick_numbers for fpl_teams and transitions the league to draft_picks_generated' do
    expect { service }
      .to change { league.reload.status }.from('initialized').to('draft_picks_generated')

    expect(league.fpl_teams.pluck(:draft_pick_number)).to all(be_an(Integer))
  end

  it 'fails if the user is not the league owner' do
    league.update(owner: create(:user))

    expect { service }.not_to change { league.reload.status }
    expect(league.fpl_teams.pluck(:draft_pick_number)).to all(be_nil)
    expect(service.errors.full_messages).to contain_exactly(
      'You are not authorised to perform this action'
    )
  end

  it 'fails if the league is not initialized' do
    league.update(status: 'draft_picks_generated')

    expect { service }.not_to change { league.reload.status }
    expect(league.fpl_teams.pluck(:draft_pick_number)).to all(be_nil)
    expect(service.errors.full_messages).to contain_exactly(
      'Draft pick numbers have already been assigned',
    )
  end
end
