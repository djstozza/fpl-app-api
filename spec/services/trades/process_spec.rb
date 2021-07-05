require 'rails_helper'

RSpec.describe Trades::Process, type: :service do
  subject(:service) { described_class.call(data, list_position, user) }
  let(:user) { create :user }
  let(:fpl_team) { create :fpl_team, owner: user }
  let(:round) { create :round, :current, deadline_time: 1.hour.from_now }
  let(:position) { create :position, :forward }
  let(:player1) { create :player, position: position }
  let(:fpl_team_list) { create :fpl_team_list, fpl_team: fpl_team, round: round }
  let!(:list_position) { create :list_position, player: player1, fpl_team_list: fpl_team_list }
  let(:player2) { create :player, position: position }
  let(:data) do
    { in_player_id: player2.id }
  end

  before { fpl_team.players << player1 }

  it 'successfully processes the trade' do
    expect { service }
      .to change { Trade.count }.from(0).to(1)
      .and change { list_position.reload.player }.from(player1).to(player2)
      .and change { fpl_team.reload.players }.from([player1]).to([player2])
      .and change { fpl_team.league.reload.players }.from([player1]).to([player2])

    trade = Trade.first

    expect(trade).to have_attributes(
      out_player: player1,
      in_player: player2,
      fpl_team_list: fpl_team_list,
    )
  end

  it 'fails if the user is not the fpl_team owner' do
    fpl_team.update(owner: create(:user))

    expect { subject }
      .to change { Trade.count }.by(0)
      .and change { list_position.reload.updated_at }.by(0)

    expect(subject.errors.full_messages).to contain_exactly('You are not authorised to perform this action')
  end

  it 'fails if the round is no longer current' do
    round.update(data_checked: true)

    expect { subject }
      .to change { Trade.count }.by(0)
      .and change { list_position.reload.updated_at }.by(0)

    expect(subject.errors.full_messages).to contain_exactly('The team list is not from the current round')
  end

  it 'fails if the deadline_time has passed' do
    round.update(deadline_time: 1.minute.ago)

    expect { subject }
      .to change { Trade.count }.by(0)
      .and change { list_position.reload.updated_at }.by(0)

    expect(subject.errors.full_messages).to contain_exactly('The trade window is now closed')
  end

  it 'fails if the in_player_id is invalid' do
    data[:in_player_id] = 'invalid'

    expect { subject }
      .to change { Trade.count }.by(0)
      .and change { list_position.reload.updated_at }.by(0)

    expect(subject.errors.full_messages).to contain_exactly('The player you have selected to waiver in does not exist')
  end

  it 'fails if the in_player does not have the same position as the out_player' do
    player2.update(position: create(:position, :midfielder))

    expect { subject }
      .to change { Trade.count }.by(0)
      .and change { list_position.reload.updated_at }.by(0)

    expect(subject.errors.full_messages).to contain_exactly('Players must have the same positions')
  end

  it 'fails if the team quota will be exceeded' do
    FplTeam::QUOTAS[:team].times do
      create(:list_position, fpl_team_list: fpl_team_list, player: create(:player, team: player2.team))
    end

    expect { subject }
      .to change { Trade.count }.by(0)
      .and change { list_position.reload.updated_at }.by(0)

    expect(service.errors.full_messages).to contain_exactly(
      "You can't have more than #{FplTeam::QUOTAS[:team]} players from the same team (#{player2.team.short_name})",
    )
  end

  it 'fails if the in_player is already part of another fpl team in the league' do
    other_fpl_team = create :fpl_team, league: fpl_team_list.league
    other_fpl_team.players << player2

    expect { subject }
      .to change { Trade.count }.by(0)
      .and change { list_position.reload.updated_at }.by(0)

    expect(service.errors.full_messages).to contain_exactly(
      'The player you have selected to trade in is already part of a team in your league'
    )
  end
end
