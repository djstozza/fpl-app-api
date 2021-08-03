require 'rails_helper'

RSpec.describe InterTeamTradeGroups::Create, type: :service do
  subject(:service) { described_class.call(data, fpl_team_list1, fpl_team_list2, user) }

  let(:round) { create :round, :current }
  let(:user) { create :user }
  let(:fpl_team1) { create :fpl_team, owner: user }
  let(:fpl_team2) { create :fpl_team, league: fpl_team1.league }
  let(:fpl_team_list1) { create :fpl_team_list, fpl_team: fpl_team1, round: round }
  let(:fpl_team_list2) { create :fpl_team_list, fpl_team: fpl_team2, round: round }

  let(:position) { create :position }
  let(:player1) { create :player, position: position }
  let(:player2) { create :player, position: position }

  let!(:list_position1) { create :list_position, player: player1, fpl_team_list: fpl_team_list1 }
  let!(:list_position2) { create :list_position, player: player2, fpl_team_list: fpl_team_list2 }

  let(:data) do
    {
      out_player_id: player1,
      in_player_id: player2,
    }
  end

  it 'successfully creates the trade group and trade' do
    expect { service }
      .to change(InterTeamTradeGroup, :count).from(0).to(1)
      .and change(InterTeamTrade, :count).from(0).to(1)

    expect(service.inter_team_trade_group).to have_attributes(
      out_fpl_team_list: fpl_team_list1,
      in_fpl_team_list: fpl_team_list2,
      status: 'pending',
    )

    expect(service.inter_team_trade).to have_attributes(
      inter_team_trade_group: service.inter_team_trade_group,
      out_player: player1,
      in_player: player2,
    )
  end

  it 'fails if the user is not the fpl_team owner' do
    fpl_team1.update(owner: create(:user))

    expect { subject }
      .to not_change { InterTeamTradeGroup.count }
      .and not_change { InterTeamTrade.count }

    expect(subject.errors.full_messages).to contain_exactly('You are not authorised to perform this action')
  end

  it 'fails if the round is no longer current' do
    round.update(data_checked: true)

    expect { subject }
      .to not_change { InterTeamTradeGroup.count }
      .and not_change { InterTeamTrade.count }

    expect(subject.errors.full_messages).to contain_exactly('This trade is not from the current round')
  end

  it 'fails if the deadline_time has passed' do
    round.update(deadline_time: 1.minute.ago)

    expect { subject }
      .to not_change { InterTeamTradeGroup.count }
      .and not_change { InterTeamTrade.count }

    expect(subject.errors.full_messages).to contain_exactly('The trade window is now closed')
  end

  it 'fails if out_player_id is invalid' do
    data[:out_player_id] = 'invalid'

    expect { subject }
      .to not_change { InterTeamTradeGroup.count }
      .and not_change { InterTeamTrade.count }

    expect(subject.errors.full_messages)
      .to contain_exactly('The player you have selected to trade out is not part of your team')
  end

  it 'fails if the in_player_id is invalid' do
    data[:in_player_id] = 'invalid'

    expect { subject }
      .to not_change { InterTeamTradeGroup.count }
      .and not_change { InterTeamTrade.count }

    expect(subject.errors.full_messages)
      .to contain_exactly("The player you have selected to trade in is not part of #{fpl_team2.name}")
  end

  it 'fails if the in_player does not have the same position as the out_player' do
    player2.update(position: create(:position, :midfielder))

    expect { subject }
      .to not_change { InterTeamTradeGroup.count }
      .and not_change { InterTeamTrade.count }

    expect(subject.errors.full_messages).to contain_exactly('Players being traded must have the same positions')
  end

  it 'fails if the team quota will be exceeded for the out_fpl_team_list' do
    FplTeam::QUOTAS[:team].times do
      create(:list_position, fpl_team_list: fpl_team_list1, player: create(:player, team: player2.team))
    end

    expect { subject }
      .to not_change { InterTeamTradeGroup.count }
      .and not_change { InterTeamTrade.count }

    expect(service.errors.full_messages).to contain_exactly(
      "You can't have more than #{FplTeam::QUOTAS[:team]} players from the same team (#{player2.team.short_name})",
    )
  end

  it 'fails if the team quota will be exceeded for the in_fpl_team_list' do
    FplTeam::QUOTAS[:team].times do
      create(:list_position, fpl_team_list: fpl_team_list2, player: create(:player, team: player1.team))
    end

    expect { subject }
      .to not_change { InterTeamTradeGroup.count }
      .and not_change { InterTeamTrade.count }

    expect(service.errors.full_messages).to contain_exactly(
      "#{fpl_team2.name} can't have more than #{FplTeam::QUOTAS[:team]} players from the same team " \
        "(#{player1.team.short_name})",
    )
  end

  it 'fails if the fpl_team_list is not from the same round' do
    fpl_team_list2.update(round: create(:round))

    expect { service }
      .to not_change { InterTeamTradeGroup.count }
      .and not_change { InterTeamTrade.count }

    expect(service.errors.full_messages).to contain_exactly('The team list you are attempting to trade with is invalid')
  end

  it 'fails if the in_fpl_team is not from the same league' do
    fpl_team2.update(league: create(:league))

    expect(service.errors.full_messages).to contain_exactly("#{fpl_team2.name} is not part of #{fpl_team1.league.name}")
  end
end
