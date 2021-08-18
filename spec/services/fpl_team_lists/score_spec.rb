require 'rails_helper'

RSpec.describe FplTeamLists::Score, :no_transaction, type: :service do
  subject(:service) { described_class.new(fpl_team_list).call }

  let(:league) { create :league, :live }
  let(:round) { create :round, is_current: true, data_checked: true }

  let(:fpl_team) { create(:fpl_team, league: league) }
  let(:fpl_team_list) { create(:fpl_team_list, fpl_team: fpl_team, round: round) }

  let(:forward) { create(:position, :forward) }
  let(:midfielder) { create(:position, :midfielder) }
  let(:defender) { create(:position, :defender) }
  let(:goalkeeper) { create(:position, :goalkeeper) }

  let(:team1) { create :team }
  let(:team2) { create :team }
  let(:team3) { create :team }
  let(:team4) { create :team }
  let(:team5) { create :team }

  let!(:fixture1) do
    create(
      :fixture,
      round: round,
      home_team: team1,
      away_team: team2,
      kickoff_time: 10.minutes.ago,
    )
  end

  let!(:fixture2) do
    create(
      :fixture,
      round: round,
      home_team: team3,
      away_team: team4,
      kickoff_time: 9.minutes.ago,
    )
  end

  let!(:fixture3) do
    create(
      :fixture,
      round: round,
      away_team: team3,
      kickoff_time: 8.minutes.ago,
    )
  end

  let!(:fixture4) do
    create(
      :fixture,
      round: round,
      home_team: team5,
      kickoff_time: 7.minutes.ago,
    )
  end

  let(:player1) do
    create(
      :player,
      position: forward,
      team: team1,
      history: [
        {
          'round' => round.external_id,
          'fixture' => fixture1.external_id,
          'opponent_team' => team2.external_id,
          'minutes' => 90,
          'total_points' => 11,
        },
      ]
    )
  end

  let(:player2) do
    create(
      :player,
      position: forward,
      team: team1,
      history: [
        {
          'round' => round.external_id,
          'fixture' => fixture1.external_id,
          'opponent_team' => team2.external_id,
          'minutes' => 90,
          'total_points' => 5,
        },
      ]
    )
  end

  let(:player3) do
    create(
      :player,
      position: forward,
      team: team1,
      history: [
        {
          'round' => round.external_id,
          'fixture' => fixture1.external_id,
          'opponent_team' => team2.external_id,
          'minutes' => 90,
          'total_points' => 5,
        },
      ]
    )
  end

  let(:player4) do
    create(
      :player,
      position: midfielder,
      team: team2,
      history: [
        {
          'round' => round.external_id,
          'fixture' => fixture1.external_id,
          'opponent_team' => team1.external_id,
          'minutes' => 90,
          'total_points' => 3,
        },
      ]
    )
  end

  let(:player5) do
    create(
      :player,
      position: midfielder,
      team: team3,
      history: [
        {
          'round' => round.external_id,
          'fixture' => fixture1.external_id,
          'opponent_team' => team4.external_id,
          'minutes' => 90,
          'total_points' => 1,
        },
      ]
    )
  end

  let(:player6) do
    create(
      :player,
      position: midfielder,
      team: team3,
      history: [
        {
          'round' => round.external_id,
          'fixture' => fixture1.external_id,
          'opponent_team' => team4.external_id,
          'minutes' => nil,
        },
        {
          'round' => round.external_id,
          'fixture' => fixture4.external_id,
          'opponent_team' => fixture4.home_team.external_id,
          'minutes' => 90,
          'total_points' => 5,
        },
      ]
    )
  end

  let(:player7) do
    create(
      :player,
      position: midfielder,
      team: team4,
      history: [
        {
          'round' => round.external_id,
          'fixture' => fixture1.external_id,
          'opponent_team' => team3.external_id,
          'minutes' => 90,
          'total_points' => 2,
        },
      ]
    )
  end

  let(:player8) do
    create(
      :player,
      position: defender,
      team: team5,
      history: [],
    )
  end

  let(:player9) do
    create(
      :player,
      position: defender,
      team: team4,
      history: []
    )
  end

  let(:player10) do
    create(
      :player,
      position: defender,
      team: team3,
      history: [
        {
          'round' => round.external_id,
          'fixture' => fixture1.external_id,
          'opponent_team' => team4.external_id,
          'minutes' => 90,
          'total_points' => 10,
        },
        {
          'round' => round.external_id,
          'fixture' => fixture4.external_id,
          'opponent_team' => fixture4.home_team.external_id,
          'minutes' => 90,
          'total_points' => 8,
        },
      ]
    )
  end

  let(:player11) do
    create(
      :player,
      position: goalkeeper,
      team: team4,
      history: []
    )
  end

  let(:player12) do
    create(
      :player,
      position: midfielder,
      team: team5,
      history: [
        {
          'round' => round.external_id,
          'fixture' => fixture4.external_id,
          'opponent_team' => fixture4.away_team.external_id,
          'minutes' => 90,
          'total_points' => 10,
        },
      ]
    )
  end

  let(:player13) do
    create(
      :player,
      position: defender,
      team: team5,
      history: [
        {
          'round' => round.external_id,
          'fixture' => fixture4.external_id,
          'opponent_team' => fixture4.away_team.external_id,
          'minutes' => 90,
          'total_points' => -1,
        },
      ]
    )
  end

  let(:player14) do
    create(
      :player,
      position: defender,
      team: team2,
      history: [
        {
          'round' => round.external_id,
          'fixture' => fixture1.external_id,
          'opponent_team' => team1.external_id,
          'minutes' => 90,
          'total_points' => -1,
        },
      ]
    )
  end

  let(:player15) do
    create(
      :player,
      position: goalkeeper,
      team: team2,
      history: [
        {
          'round' => round.external_id,
          'fixture' => fixture1.external_id,
          'opponent_team' => team1.external_id,
          'minutes' => 90,
          'total_points' => 2,
        },
      ]
    )
  end

  let!(:list_position1) { create :list_position, :starting, player: player1, fpl_team_list: fpl_team_list }
  let!(:list_position2) { create :list_position, :starting, player: player2, fpl_team_list: fpl_team_list }
  let!(:list_position3) { create :list_position, :starting, player: player3, fpl_team_list: fpl_team_list }
  let!(:list_position4) { create :list_position, :starting, player: player4, fpl_team_list: fpl_team_list }
  let!(:list_position5) { create :list_position, :starting, player: player5, fpl_team_list: fpl_team_list }
  let!(:list_position6) { create :list_position, :starting, player: player6, fpl_team_list: fpl_team_list }
  let!(:list_position7) { create :list_position, :starting, player: player7, fpl_team_list: fpl_team_list }
  let!(:list_position8) { create :list_position, :starting, player: player8, fpl_team_list: fpl_team_list }
  let!(:list_position9) { create :list_position, :starting, player: player9, fpl_team_list: fpl_team_list }
  let!(:list_position10) { create :list_position, :starting, player: player10, fpl_team_list: fpl_team_list }
  let!(:list_position11) { create :list_position, :starting, player: player11, fpl_team_list: fpl_team_list }
  let!(:list_position12) { create :list_position, :substitute_1, player: player12, fpl_team_list: fpl_team_list }
  let!(:list_position13) { create :list_position, :substitute_2, player: player13, fpl_team_list: fpl_team_list }
  let!(:list_position14) { create :list_position, :substitute_3, player: player14, fpl_team_list: fpl_team_list }
  let!(:list_position15) { create :list_position, :substitute_gkp, player: player15, fpl_team_list: fpl_team_list }

  it 'substitutes players where possible and calculates the total score' do
    # list_position12 may be 'substitute_1' but was skipped since it would not be a valid substitution, as only 2
    # starting defenders would be in the team

    # player9 is subbed out prior to player8 because player9's fixture started earlier

    expect { service }
      .to change { list_position8.reload.role }.from('starting').to('substitute_3')
      .and change { list_position9.reload.role }.from('starting').to('substitute_2')
      .and change { list_position11.reload.role }.from('starting').to('substitute_gkp')
      .and change { list_position13.reload.role }.from('substitute_2').to('starting')
      .and change { list_position14.reload.role }.from('substitute_3').to('starting')
      .and change { list_position15.reload.role }.from('substitute_gkp').to('starting')
      .and change { fpl_team_list.reload.total_score }.from(nil).to(50)
      .and not_change { list_position12.reload.role }
      .and not_change { list_position6.reload.role }
  end

  it 'does not sub out starters with upcoming fixtures but does sub in substitutes with upcoming fixtures' do
    fixture4.update(finished: false)
    player13.update(history: [])
    # player8 will not be subbed outbecause the fixture hasn't finished yet but player13 will be subbed in for player9

    expect { service }
      .to change { list_position9.reload.role }.from('starting').to('substitute_2')
      .and change { list_position11.reload.role }.from('starting').to('substitute_gkp')
      .and change { list_position13.reload.role }.from('substitute_2').to('starting')
      .and change { list_position15.reload.role }.from('substitute_gkp').to('starting')
      .and change { fpl_team_list.reload.total_score }.from(nil).to(52)
      .and not_change { list_position12.reload.role }
      .and not_change { list_position6.reload.role }
      .and not_change { list_position8.reload.role }
      .and not_change { list_position14.reload.role }
  end

  it 'does not sub in players with no minutes if their fixtures have finished' do
    player13.update(history: [])

    # player9 will be subbed with player14, even though player14 is 'substitute_3' since
    # player13 did not play any minutes

    # player8 will not be substituted since there are no valid substitutions left

    expect { service }
      .to change { list_position9.reload.role }.from('starting').to('substitute_3')
      .and change { list_position11.reload.role }.from('starting').to('substitute_gkp')
      .and change { list_position14.reload.role }.from('substitute_3').to('starting')
      .and change { list_position15.reload.role }.from('substitute_gkp').to('starting')
      .and change { fpl_team_list.reload.total_score }.from(nil).to(51)
      .and not_change { list_position12.reload.role }
      .and not_change { list_position6.reload.role }
      .and not_change { list_position8.reload.role }
      .and not_change { list_position13.reload.role }
  end
end
