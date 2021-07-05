require 'rails_helper'

RSpec.describe WaiverPicks::Destroy, type: :service do
  subject(:service) { described_class.call(waiver_pick, user) }
  let(:user) { create :user }
  let(:fpl_team) { create :fpl_team, owner: user }
  let(:round) { create :round, :current }
  let(:fpl_team_list) { create :fpl_team_list, fpl_team: fpl_team, round: round }
  let!(:waiver_pick1) { create :waiver_pick, pick_number: 1, fpl_team_list: fpl_team_list }
  let!(:waiver_pick2) { create :waiver_pick, pick_number: 2, fpl_team_list: fpl_team_list }
  let!(:waiver_pick3) { create :waiver_pick, pick_number: 3, fpl_team_list: fpl_team_list }
  let!(:waiver_pick4) { create :waiver_pick, pick_number: 4, fpl_team_list: fpl_team_list }
  let(:waiver_pick) { waiver_pick1 }

  context 'waiver_picks with higher pick numbers present' do
    it 'destroys the waiver_pick and reduces the pick_numbers that are higher than it by 1' do
      expect { service }
        .to change { WaiverPick.count }.from(4).to(3)
        .and change { waiver_pick2.reload.pick_number }.from(2).to(1)
        .and change { waiver_pick3.reload.pick_number }.from(3).to(2)
        .and change { waiver_pick4.reload.pick_number }.from(4).to(3)
    end
  end

  context 'waiver_picks with lower pick numbers present' do
    let(:waiver_pick) { waiver_pick4 }

    it 'destroys the waiver_pick but does not change pick numbers that are lower' do
      expect { service }
        .to change { WaiverPick.count }.from(4).to(3)
        .and change { waiver_pick1.reload.updated_at }.by(0)
        .and change { waiver_pick2.reload.updated_at }.by(0)
        .and change { waiver_pick3.reload.updated_at }.by(0)
    end
  end

  it 'fails if the user is not the fpl_team owner' do
    fpl_team.update(owner: create(:user))

    expect { subject }
      .to change { WaiverPick.count }.by(0)
      .and change { waiver_pick1.reload.updated_at }.by(0)
      .and change { waiver_pick2.reload.updated_at }.by(0)
      .and change { waiver_pick3.reload.updated_at }.by(0)
      .and change { waiver_pick4.reload.updated_at }.by(0)

    expect(subject.errors.full_messages).to contain_exactly('You are not authorised to perform this action')
  end

  it 'fails if the round is no longer current' do
    round.update(data_checked: true)

    expect { subject }
      .to change { WaiverPick.count }.by(0)
      .and change { waiver_pick1.reload.updated_at }.by(0)
      .and change { waiver_pick2.reload.updated_at }.by(0)
      .and change { waiver_pick3.reload.updated_at }.by(0)
      .and change { waiver_pick4.reload.updated_at }.by(0)

    expect(subject.errors.full_messages).to contain_exactly('The team list is not from the current round')
  end

  it 'fails if the deadline_time has passed' do
    round.update(deadline_time: 23.hours.from_now)

    expect { subject }
      .to change { WaiverPick.count }.by(0)
      .and change { waiver_pick1.reload.updated_at }.by(0)
      .and change { waiver_pick2.reload.updated_at }.by(0)
      .and change { waiver_pick3.reload.updated_at }.by(0)
      .and change { waiver_pick4.reload.updated_at }.by(0)

    expect(subject.errors.full_messages).to contain_exactly('The waiver deadline has passed')
  end

  it 'fails if the waiver_pick is no longer pending' do
    waiver_pick1.update(status: 'approved')

    expect { subject }
      .to change { WaiverPick.count }.by(0)
      .and change { waiver_pick1.reload.updated_at }.by(0)
      .and change { waiver_pick2.reload.updated_at }.by(0)
      .and change { waiver_pick3.reload.updated_at }.by(0)
      .and change { waiver_pick4.reload.updated_at }.by(0)

    expect(subject.errors.full_messages).to contain_exactly('Only pending waiver picks can be changed')
  end
end
