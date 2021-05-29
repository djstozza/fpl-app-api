require 'rails_helper'

RSpec.describe Leagues::CreateDraft, type: :service do
  subject(:service) { described_class.call(league, user) }
  let(:user) { create :user }
  let(:league) { create :league, owner: user, status: 'draft_picks_generated' }

  context 'fpl_team quota reached' do
    before do
      (League::MIN_FPL_TEAM_QUOTA).times do |i|
        create(:fpl_team, league: league, draft_pick_number: i + 1)
      end
    end

    it 'creates draft_pick_numbers for fpl_teams and transitions the league to draft_picks_generated' do
      expect { service }
        .to change { league.reload.status }.from('draft_picks_generated').to('draft')
        .and change { league.draft_picks.count }.from(0).to(League::MIN_FPL_TEAM_QUOTA * League::PICKS_PER_TEAM)
    end

    it 'fails if the user is not the league owner' do
      league.update(owner: create(:user))

      expect { service }
        .to change { league.reload.updated_at }.by(0)
        .and change { league.draft_picks.count }.by(0)

      expect(service.errors.full_messages).to contain_exactly(
        'You are not authorised to perform this action'
      )
    end

    it 'fails if the league does not have the draft_picks_generated status' do
      league.update(status: 'initialized')

      expect { service }
        .to change { league.reload.updated_at }.by(0)
        .and change { league.draft_picks.count }.by(0)

      expect(service.errors.full_messages).to contain_exactly(
        'You cannot create a draft at this time',
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
      expect { service }
        .to change { league.reload.updated_at }.by(0)
        .and change { league.draft_picks.count }.by(0)

      expect(service.errors.full_messages).to contain_exactly(
        "There must be at least #{League::MIN_FPL_TEAM_QUOTA} teams present"
      )
    end
  end
end
