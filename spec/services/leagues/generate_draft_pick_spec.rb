require 'rails_helper'

RSpec.describe Leagues::GenerateDraftPick, type: :service do
  subject(:service) { described_class.call(league, user) }
  let(:user) { create :user }
  let(:league) { create :league, owner: user, status: 'initialized' }

  context 'fpl_team quota reached' do
    before do
      (League::MIN_FPL_TEAM_QUOTA).times do
        create(:fpl_team, league: league)
      end
    end

    it 'creates draft picks for all the fpl_teams' do
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

  context 'fpl_team quota not reached' do
    before do
      (League::MIN_FPL_TEAM_QUOTA - 1).times do
        create(:fpl_team, league: league)
      end
    end

    it 'fails if the fpl_team quota has not been reached' do
      expect { service }.not_to change { league.reload.status }

      expect(service.errors.full_messages).to contain_exactly(
        "There must be at least #{League::MIN_FPL_TEAM_QUOTA} teams present"
      )
    end
  end
end
