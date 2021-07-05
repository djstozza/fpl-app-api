require 'rails_helper'

RSpec.describe WaiverPicks::Create, type: :service do
  subject(:service) { described_class.call(data, fpl_team_list, user) }
  let(:user) { create :user }
  let(:fpl_team) { create :fpl_team, owner: user }
  let(:round) { create :round, :current }
  let(:position) { create :position, :forward }
  let(:player1) { create :player, position: position }
  let(:fpl_team_list) { create :fpl_team_list, fpl_team: fpl_team, round: round }
  let!(:list_position) { create :list_position, player: player1, fpl_team_list: fpl_team_list }
  let(:player2) { create :player, position: position }
  let(:data) do
    {
      out_player_id: player1.id,
      in_player_id: player2.id,
    }
  end

  it 'successfully creates the waiver_pick' do
    expect { service }
      .to change { WaiverPick.count }.from(0).to(1)

    waiver_pick = WaiverPick.first

    expect(waiver_pick).to have_attributes(
      fpl_team_list_id: fpl_team_list.id,
      out_player_id: player1.id,
      in_player_id: player2.id,
      status: 'pending',
      pick_number: 1,
    )
  end

  it 'fails if the user is not the fpl_team owner' do
    fpl_team.update(owner: create(:user))

    expect { subject }
      .not_to change { WaiverPick.count }

    expect(subject.errors.full_messages).to contain_exactly('You are not authorised to perform this action')
  end

  it 'fails if the round is no longer current' do
    round.update(data_checked: true)

    expect { subject }
      .not_to change { WaiverPick.count }

    expect(subject.errors.full_messages).to contain_exactly('Round is not current')
  end

  it 'fails if the deadline_time has passed' do
    round.update(deadline_time: 23.hours.from_now)

    expect { subject }
      .not_to change { WaiverPick.count }

    expect(subject.errors.full_messages).to contain_exactly('The waiver deadline has passed')
  end

  it 'fails if out_player_id is invalid' do
    data[:out_player_id] = 'invalid'

    expect { subject }
      .not_to change { WaiverPick.count }

    expect(subject.errors.full_messages)
      .to contain_exactly('The player you have selected to waiver out is not part of your team')
  end

  it 'fails if the in_player_id is invalid' do
    data[:in_player_id] = 'invalid'

    expect { subject }
      .not_to change { WaiverPick.count }

    expect(subject.errors.full_messages).to contain_exactly('The player you have selected to waiver in does not exist')
  end

  it 'fails if the in_player does not have the same position as the out_player' do
    player2.update(position: create(:position, :midfielder))

    expect { subject }
      .not_to change { WaiverPick.count }

    expect(subject.errors.full_messages).to contain_exactly('Players being waivered must have the same positions')
  end

  it 'fails if the team quota will be exceeded' do
    FplTeam::QUOTAS[:team].times do
      create(:list_position, fpl_team_list: fpl_team_list, player: create(:player, team: player2.team))
    end

    expect { subject }
      .not_to change { WaiverPick.count }

    expect(service.errors.full_messages).to contain_exactly(
      "You can't have more than #{FplTeam::QUOTAS[:team]} players from the same team (#{player2.team.short_name})",
    )
  end

  it 'fails if the waiver pick is a dupliate' do
    existing_waiver_pick = create(:waiver_pick, fpl_team_list: fpl_team_list, out_player: player1, in_player: player2)

    expect { subject }
      .not_to change { WaiverPick.count }

    expect(service.errors.full_messages).to contain_exactly(
      "Duplicate waiver pick - (Pick number: #{existing_waiver_pick.pick_number} Out: #{player1.name}, " \
        "In: #{player2.name})"
    )
  end

  it 'fails if the in_player is already part of another fpl team in the league' do
    other_fpl_team = create :fpl_team, league: fpl_team_list.league
    other_fpl_team.players << player2

    expect { subject }
      .not_to change { WaiverPick.count }

    expect(service.errors.full_messages).to contain_exactly(
      'The player you have selected to waiver in is already part of a team in your league'
    )
  end
end
