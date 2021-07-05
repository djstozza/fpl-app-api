require 'rails_helper'

RSpec.describe WaiverPicks::Approve, type: :service do
  subject(:service) { described_class.call(waiver_pick) }
  let(:user) { create :user }
  let(:fpl_team) { create :fpl_team, owner: user }
  let(:round) { create :round, :current, deadline_time: 23.hours.from_now }
  let(:position) { create :position, :forward }
  let(:player1) { create :player, position: position }
  let(:fpl_team_list) { create :fpl_team_list, fpl_team: fpl_team, round: round }
  let!(:list_position) { create :list_position, player: player1, fpl_team_list: fpl_team_list }
  let(:player2) { create :player, position: position }
  let!(:waiver_pick) { create :waiver_pick, fpl_team_list: fpl_team_list, out_player: player1, in_player: player2 }

  before { fpl_team.players << player1 }

  it 'approves the waiver_pick and changes the fpl_team line up' do
    expect { service }
      .to change { list_position.reload.player }.from(player1).to(player2)
      .and change { waiver_pick.reload.status }.from('pending').to('approved')
      .and change { fpl_team.reload.players }.from([player1]).to([player2])
      .and change { fpl_team.league.reload.players }.from([player1]).to([player2])
  end

  it 'fails if the round is no longer current' do
    round.update(data_checked: true)

    expect { subject }
      .to change { list_position.reload.updated_at }.by(0)
      .and change { waiver_pick.reload.updated_at }.by(0)

    expect(fpl_team.reload.players).to include(player1)
    expect(fpl_team.reload.players).not_to include(player2)
    expect(fpl_team.league.reload.players).to include(player1)
    expect(fpl_team.league.reload.players).not_to include(player2)

    expect(subject.errors.full_messages).to contain_exactly('The team list is not from the current round')
  end

  it 'fails if the deadline_time has not passed' do
    round.update(deadline_time: 2.days.from_now)

    expect { subject }
      .to change { list_position.reload.updated_at }.by(0)
      .and change { waiver_pick.reload.updated_at }.by(0)

    expect(fpl_team.reload.players).to include(player1)
    expect(fpl_team.reload.players).not_to include(player2)
    expect(fpl_team.league.reload.players).to include(player1)
    expect(fpl_team.league.reload.players).not_to include(player2)

    expect(subject.errors.full_messages).to contain_exactly('The waiver deadline has not passed yet')
  end

  it 'does not update the waiver pick if the in_player is already part of the fpl_team' do
    fpl_team.players << player2

    expect { subject }
      .to change { list_position.reload.updated_at }.by(0)
      .and change { waiver_pick.reload.updated_at }.by(0)

    expect(fpl_team.reload.players).to include(player1, player2)
    expect(fpl_team.league.reload.players).to include(player1, player2)
  end


  it 'does not update the waiver pick if the in_player is already part of the league' do
    another_fpl_team = create(:fpl_team, league: fpl_team.league)
    another_fpl_team.players << player2


    expect { subject }
      .to change { list_position.reload.updated_at }.by(0)
      .and change { waiver_pick.reload.updated_at }.by(0)

    expect(fpl_team.reload.players).to include(player1)
    expect(fpl_team.reload.players).not_to include(player2)
    expect(fpl_team.league.reload.players).to include(player1, player2)
  end

  it 'fails if the waiver_pick is no longer pending' do
    waiver_pick.update(status: 'approved')

    expect { subject }
    .to change { list_position.reload.updated_at }.by(0)
    .and change { waiver_pick.reload.updated_at }.by(0)

    expect(fpl_team.reload.players).to include(player1)
    expect(fpl_team.reload.players).not_to include(player2)
    expect(fpl_team.league.reload.players).to include(player1)
    expect(fpl_team.league.reload.players).not_to include(player2)

    expect(subject.errors.full_messages).to contain_exactly('Only pending waiver picks can be changed')
  end
end
