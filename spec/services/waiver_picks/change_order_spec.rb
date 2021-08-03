require 'rails_helper'

RSpec.describe WaiverPicks::ChangeOrder, type: :service do
  subject(:service) { described_class.call(data, waiver_pick, user) }

  let(:user) { create :user }
  let(:fpl_team) { create :fpl_team, owner: user }
  let(:round) { create :round, :current }
  let(:fpl_team_list) { create :fpl_team_list, fpl_team: fpl_team, round: round }
  let!(:waiver_pick1) { create :waiver_pick, pick_number: 1, fpl_team_list: fpl_team_list }
  let!(:waiver_pick2) { create :waiver_pick, pick_number: 2, fpl_team_list: fpl_team_list }
  let!(:waiver_pick3) { create :waiver_pick, pick_number: 3, fpl_team_list: fpl_team_list }
  let!(:waiver_pick4) { create :waiver_pick, pick_number: 4, fpl_team_list: fpl_team_list }
  let(:waiver_pick) { waiver_pick1 }
  let(:data) do
    { new_pick_number: 3 }
  end

  context 'when moving down the order' do
    it 'successfully changes the order' do
      expect { service }
        .to change { waiver_pick1.reload.pick_number }.from(1).to(3)
        .and change { waiver_pick2.reload.pick_number }.from(2).to(1)
        .and change { waiver_pick3.reload.pick_number }.from(3).to(2)
        .and not_change { waiver_pick4.reload.updated_at }
    end
  end

  context 'when moving up the order' do
    let(:waiver_pick) { waiver_pick4 }

    it 'successfully changes the order' do
      data[:new_pick_number] = 1

      expect { service }
        .to change { waiver_pick1.reload.pick_number }.from(1).to(2)
        .and change { waiver_pick2.reload.pick_number }.from(2).to(3)
        .and change { waiver_pick3.reload.pick_number }.from(3).to(4)
        .and change { waiver_pick4.reload.pick_number }.from(4).to(1)
    end
  end

  it 'fails if the user is not the fpl_team owner' do
    fpl_team.update(owner: create(:user))

    expect { subject }
      .to not_change { waiver_pick1.reload.updated_at }
      .and not_change { waiver_pick2.reload.updated_at }
      .and not_change { waiver_pick3.reload.updated_at }
      .and not_change { waiver_pick4.reload.updated_at }

    expect(subject.errors.full_messages).to contain_exactly('You are not authorised to perform this action')
  end

  it 'fails if the round is no longer current' do
    round.update(data_checked: true)

    expect { subject }
      .to not_change { waiver_pick1.reload.updated_at }
      .and not_change { waiver_pick2.reload.updated_at }
      .and not_change { waiver_pick3.reload.updated_at }
      .and not_change { waiver_pick4.reload.updated_at }

    expect(subject.errors.full_messages).to contain_exactly('The team list is not from the current round')
  end

  it 'fails if the deadline_time has passed' do
    round.update(deadline_time: 23.hours.from_now)

    expect { subject }
      .to not_change { waiver_pick1.reload.updated_at }
      .and not_change { waiver_pick2.reload.updated_at }
      .and not_change { waiver_pick3.reload.updated_at }
      .and not_change { waiver_pick4.reload.updated_at }

    expect(subject.errors.full_messages).to contain_exactly('The waiver deadline has passed')
  end

  it 'fails if new_pick_number is invalid' do
    data[:new_pick_number] = WaiverPick.count + 1

    expect { subject }
      .to not_change { waiver_pick1.reload.updated_at }
      .and not_change { waiver_pick2.reload.updated_at }
      .and not_change { waiver_pick3.reload.updated_at }
      .and not_change { waiver_pick4.reload.updated_at }

    expect(subject.errors.full_messages)
      .to contain_exactly('Pick number is invalid')
  end

  it 'fails if the new_pick_number is the same as the original' do
    data[:new_pick_number] = 1

    expect { subject }
      .to not_change { waiver_pick1.reload.updated_at }
      .and not_change { waiver_pick2.reload.updated_at }
      .and not_change { waiver_pick3.reload.updated_at }
      .and not_change { waiver_pick4.reload.updated_at }

    expect(subject.errors.full_messages).to contain_exactly('No change in pick number')
  end

  it 'fails if the waiver_pick is no longer pending' do
    waiver_pick1.update(status: 'approved')

    expect { subject }
      .to not_change { waiver_pick1.reload.updated_at }
      .and not_change { waiver_pick2.reload.updated_at }
      .and not_change { waiver_pick3.reload.updated_at }
      .and not_change { waiver_pick4.reload.updated_at }

    expect(subject.errors.full_messages).to contain_exactly('Only pending waiver picks can be changed')
  end
end
