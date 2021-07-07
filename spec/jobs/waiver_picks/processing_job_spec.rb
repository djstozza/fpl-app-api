require 'rails_helper'

RSpec.describe WaiverPicks::ProcessingJob do
  let(:league) { create :league, status: 'live' }
  let(:round) { create :round, :current, deadline_time: 23.hours.from_now }
  let(:position) { create :position, :forward }

  let(:fpl_team1) { create :fpl_team, league: league, rank: 1 }
  let(:fpl_team_list1) { create :fpl_team_list, fpl_team: fpl_team1, round: round }

  let(:fpl_team2) { create :fpl_team, league: league, rank: 2 }
  let(:fpl_team_list2) { create :fpl_team_list, fpl_team: fpl_team2, round: round }

  let(:fpl_team3) { create :fpl_team, league: league, rank: 3 }
  let(:fpl_team_list3) { create :fpl_team_list, fpl_team: fpl_team3, round: round }

  let(:player1) { create :player, position: position }
  let(:player2) { create :player, position: position }
  let(:player3) { create :player, position: position }
  let(:player4) { create :player, position: position }
  let(:player5) { create :player, position: position }
  let(:player6) { create :player, position: position }

  let!(:list_position1) { create :list_position, player: player1, fpl_team_list: fpl_team_list1 }
  let!(:list_position2) { create :list_position, player: player2, fpl_team_list: fpl_team_list2 }
  let!(:list_position3) { create :list_position, player: player3, fpl_team_list: fpl_team_list3 }

  let!(:waiver_pick1) do
    create(
      :waiver_pick,
      fpl_team_list: fpl_team_list1,
      pick_number: 1,
      out_player: player1,
      in_player: player4,
    )
  end
  let!(:waiver_pick2) do
    create(
      :waiver_pick,
      fpl_team_list: fpl_team_list1,
      pick_number: 2,
      out_player: player1,
      in_player: player5,
    )
  end
  let!(:waiver_pick3) do
    create(
      :waiver_pick,
      fpl_team_list: fpl_team_list1,
      pick_number: 3,
      out_player: player1,
      in_player: player6,
    )
  end
  let!(:waiver_pick4) do
    create(
      :waiver_pick,
      fpl_team_list: fpl_team_list2,
      pick_number: 1,
      out_player: player2,
      in_player: player4,
    )
  end
  let!(:waiver_pick5) do
    create(
      :waiver_pick,
      fpl_team_list: fpl_team_list2,
      pick_number: 2,
      out_player: player2,
      in_player: player6,
    )
  end
  let!(:waiver_pick6) do
    create(
      :waiver_pick,
      fpl_team_list: fpl_team_list3,
      pick_number: 1,
      out_player: player3,
      in_player: player4,
    )
  end

  before do
    fpl_team1.players << player1
    fpl_team2.players << player2
    fpl_team3.players << player3
  end

  it 'approves and declines the waiver picks' do
    expect { described_class.perform_now(round.id) }
      .to change { waiver_pick1.reload.status }.from('pending').to('declined')
      .and change { waiver_pick2.reload.status }.from('pending').to('approved')
      .and change { waiver_pick3.reload.status }.from('pending').to('declined')
      .and change { waiver_pick4.reload.status }.from('pending').to('declined')
      .and change { waiver_pick5.reload.status }.from('pending').to('approved')
      .and change { waiver_pick6.reload.status }.from('pending').to('approved')
      .and change { list_position1.reload.player }.from(player1).to(player5)
      .and change { list_position2.reload.player }.from(player2).to(player6)
      .and change { list_position3.reload.player }.from(player3).to(player4)
      .and change { fpl_team1.reload.players }.from([player1]).to([player5])
      .and change { fpl_team2.reload.players }.from([player2]).to([player6])
      .and change { fpl_team3.reload.players }.from([player3]).to([player4])
  end

  it 'returns if the round is not current' do
    round.update(data_checked: true)

    expect(WaiverPicks::Approve).not_to receive(:call)

    described_class.perform_now(round.id)
  end

  it 'returns if the waiver deadline has not passed' do
    round.update(deadline_time: 2.days.from_now)

    expect(WaiverPicks::Approve).not_to receive(:call)

    described_class.perform_now(round.id)
  end
end
