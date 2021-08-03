require 'rails_helper'

RSpec.describe InterTeamTradeGroups::Submit, type: :service do
  subject(:service) { described_class.call(inter_team_trade_group, user) }

  let(:round) { create :round, :current }
  let(:user) { create :user }
  let(:fpl_team1) { create :fpl_team, owner: user }
  let(:fpl_team2) { create :fpl_team, league: fpl_team1.league }
  let(:fpl_team_list1) { create :fpl_team_list, fpl_team: fpl_team1, round: round }
  let(:fpl_team_list2) { create :fpl_team_list, fpl_team: fpl_team2, round: round }

  let(:position) { create :position }
  let(:player1) { create :player, position: position }
  let(:player2) { create :player, position: position }
  let(:player3) { create :player, position: position }
  let(:player4) { create :player, position: position }

  let!(:list_position1) { create :list_position, player: player1, fpl_team_list: fpl_team_list1 }
  let!(:list_position2) { create :list_position, player: player2, fpl_team_list: fpl_team_list1 }
  let!(:list_position3) { create :list_position, player: player3, fpl_team_list: fpl_team_list2 }
  let!(:list_position4) { create :list_position, player: player4, fpl_team_list: fpl_team_list2 }

  let(:inter_team_trade_group) do
    create(
      :inter_team_trade_group,
      out_fpl_team_list: fpl_team_list1,
      in_fpl_team_list: fpl_team_list2,
    )
  end

  let!(:inter_team_trade1) do
    create(
      :inter_team_trade,
      out_player: player1,
      in_player: player3,
      inter_team_trade_group: inter_team_trade_group,
    )
  end

  let!(:inter_team_trade2) do
    create(
      :inter_team_trade,
      out_player: player2,
      in_player: player4,
      inter_team_trade_group: inter_team_trade_group,
    )
  end

  it 'changes the inter_team_trade_group status to submitted' do
    expect { service }
      .to change { inter_team_trade_group.reload.status }.from('pending').to('submitted')
  end

  it 'fails if the user is not the fpl_team owner' do
    fpl_team1.update(owner: create(:user))

    expect { subject }.to not_change { inter_team_trade_group.reload.updated_at }

    expect(subject.errors.full_messages).to contain_exactly('You are not authorised to perform this action')
  end

  it 'fails if the round is no longer current' do
    round.update(data_checked: true)

    expect { subject }.to not_change { inter_team_trade_group.reload.updated_at }

    expect(subject.errors.full_messages).to contain_exactly('This trade is not from the current round')
  end

  it 'fails if the deadline_time has passed' do
    round.update(deadline_time: 1.minute.ago)

    expect { subject }.to not_change { inter_team_trade_group.reload.updated_at }

    expect(subject.errors.full_messages).to contain_exactly('The trade window is now closed')
  end

  it 'fails if not all the players are part of the out_fpl_team_list' do
    list_position1.update(player: create(:player))

    expect { subject }.to not_change { inter_team_trade_group.reload.updated_at }

    expect(subject.errors.full_messages)
      .to contain_exactly("Not all the players in this proposed trade are in your team: #{player1.name}")
  end

  it 'fails if not all the players are part of the in_fpl_team_list' do
    list_position3.update(player: create(:player))

    expect { subject }.to not_change { inter_team_trade_group.reload.updated_at }

    expect(subject.errors.full_messages)
      .to contain_exactly("Not all the players in this proposed trade are in #{fpl_team2.name}: #{player3.name}")
  end

  it 'fails if the team quota will be exceeded for the out_fpl_team_list' do
    FplTeam::QUOTAS[:team].times do
      create(:list_position, fpl_team_list: fpl_team_list1, player: create(:player, team: player4.team))
    end

    expect { subject }.to not_change { inter_team_trade_group.reload.updated_at }

    expect(service.errors.full_messages).to contain_exactly(
      "You can't have more than #{FplTeam::QUOTAS[:team]} players from the same team (#{player4.team.short_name})",
    )
  end

  it 'fails if the team quota will be exceeded for the in_fpl_team_list' do
    FplTeam::QUOTAS[:team].times do
      create(:list_position, fpl_team_list: fpl_team_list2, player: create(:player, team: player2.team))
    end

    expect { subject }.to not_change { inter_team_trade_group.reload.updated_at }

    expect(service.errors.full_messages).to contain_exactly(
      "#{fpl_team2.name} can't have more than #{FplTeam::QUOTAS[:team]} players from the same team " \
        "(#{player2.team.short_name})",
    )
  end

  it 'fails if the inter_team_trade_group is not pending' do
    inter_team_trade_group.update(status: 'approved')

    expect { subject }.to not_change { inter_team_trade_group.reload.updated_at }

    expect(service.errors.full_messages).to contain_exactly('Changes can no longer be made to the proposed trade')
  end

  it 'fails if this is a duplicate trade proposal' do
    another_inter_team_trade_group = create(
      :inter_team_trade_group,
      :submitted,
      out_fpl_team_list: fpl_team_list1,
      in_fpl_team_list: fpl_team_list2,
    )

    create(
      :inter_team_trade,
      inter_team_trade_group: another_inter_team_trade_group,
      out_player: player1,
      in_player: player3,
    )

    create(
      :inter_team_trade,
      inter_team_trade_group: another_inter_team_trade_group,
      out_player: player2,
      in_player: player4,
    )

    expect { subject }.to not_change { inter_team_trade_group.reload.updated_at }

    expect(subject.errors.full_messages).to contain_exactly('You have already proposed this trade')
  end
end
