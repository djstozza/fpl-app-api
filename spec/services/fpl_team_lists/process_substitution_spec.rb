require 'rails_helper'

RSpec.describe FplTeamLists::ProcessSubstitution, :no_transaction, type: :service do
  subject(:service) { described_class.call(data, fpl_team_list, user) }
  let(:data) do
    {
      out_list_position_id: list_position8.id,
      in_list_position_id: list_position13.id,
    }
  end
  let(:user) { create :user }
  let(:fpl_team) { create :fpl_team, owner: user }
  let(:round) { create :round, :current }
  let(:fpl_team_list) { create :fpl_team_list, fpl_team: fpl_team, round: round }

  let!(:list_position1) { create :list_position, :starting, :forward, fpl_team_list_id: fpl_team_list.id }
  let!(:list_position2) { create :list_position, :starting, :forward, fpl_team_list_id: fpl_team_list.id }
  let!(:list_position3) { create :list_position, :starting, :forward, fpl_team_list_id: fpl_team_list.id }
  let!(:list_position4) { create :list_position, :starting, :midfielder, fpl_team_list_id: fpl_team_list.id }
  let!(:list_position5) { create :list_position, :starting, :midfielder, fpl_team_list_id: fpl_team_list.id }
  let!(:list_position6) { create :list_position, :starting, :midfielder, fpl_team_list_id: fpl_team_list.id }
  let!(:list_position7) { create :list_position, :starting, :midfielder, fpl_team_list_id: fpl_team_list.id }
  let!(:list_position8) { create :list_position, :starting, :defender, fpl_team_list_id: fpl_team_list.id }
  let!(:list_position9) { create :list_position, :starting, :defender, fpl_team_list_id: fpl_team_list.id }
  let!(:list_position10) { create :list_position, :starting, :defender, fpl_team_list_id: fpl_team_list.id }
  let!(:list_position11) { create :list_position, :starting, :goalkeeper, fpl_team_list_id: fpl_team_list.id }
  let!(:list_position12) { create :list_position, :substitute_1, :midfielder, fpl_team_list_id: fpl_team_list.id }
  let!(:list_position13) { create :list_position, :substitute_2, :defender, fpl_team_list_id: fpl_team_list.id }
  let!(:list_position14) { create :list_position, :substitute_3, :defender, fpl_team_list_id: fpl_team_list.id }
  let!(:list_position15) { create :list_position, :substitute_gkp, :goalkeeper, fpl_team_list_id: fpl_team_list.id }

  it 'processes the substitution' do
    expect { subject }
      .to change { list_position8.reload.role }.from('starting').to('substitute_2')
      .and change { list_position13.reload.role }.from('substitute_2').to('starting')
  end

  it 'fails if the user is not the fpl_team owner' do
    fpl_team.update(owner: create(:user))

    expect { subject }
      .to change { list_position8.reload.updated_at }.by(0)
      .and change { list_position13.reload.updated_at }.by(0)

    expect(subject.errors.full_messages).to contain_exactly('You are not authorised to perform this action')
  end

  it 'fails if the round is no longer current' do
    round.update(data_checked: true)

    expect { subject }
      .to change { list_position8.reload.updated_at }.by(0)
      .and change { list_position13.reload.updated_at }.by(0)

    expect(subject.errors.full_messages).to contain_exactly('The team list is not from the current round')
  end

  it 'fails if the deadline_time has passed' do
    round.update(deadline_time: 1.minute.ago)

    expect { subject }
      .to change { list_position8.reload.updated_at }.by(0)
      .and change { list_position13.reload.updated_at }.by(0)

    expect(subject.errors.full_messages).to contain_exactly('The time for making substitutions has passed')
  end

  it 'fails if the out_list_position_id is invalid' do
    data[:out_list_position_id] = 'invalid'

    expect { subject }
      .to change { list_position8.reload.updated_at }.by(0)
      .and change { list_position13.reload.updated_at }.by(0)

    expect(subject.errors.full_messages).to contain_exactly('Player being subbed out cannot be found')
  end

  it 'fails if the in_list_position_id is invalid' do
    data[:in_list_position_id] = 'invalid'

    expect { subject }
      .to change { list_position8.reload.updated_at }.by(0)
      .and change { list_position13.reload.updated_at }.by(0)

    expect(subject.errors.full_messages).to contain_exactly('Player being subbed in cannot be found')
  end

  it 'fails if the substitution is invalid' do
    data[:in_list_position_id] = list_position12.id

    expect { subject }
      .to change { list_position8.reload.updated_at }.by(0)
      .and change { list_position12.reload.updated_at }.by(0)

    expect(subject.errors.full_messages).to contain_exactly('Invalid substitution')
  end
end
