require 'rails_helper'

RSpec.describe InterTeamTradeGroups::RemoveTrade, type: :service do
  subject(:service) { described_class.call(inter_team_trade, user) }

  let(:round) { create :round, :current }
  let(:user) { create :user }
  let(:fpl_team) { create :fpl_team, owner: user }
  let(:fpl_team_list) { create :fpl_team_list, fpl_team: fpl_team, round: round }
  let(:inter_team_trade_group) { create :inter_team_trade_group, out_fpl_team_list: fpl_team_list }

  let!(:inter_team_trade) { create :inter_team_trade, inter_team_trade_group: inter_team_trade_group }

  it 'deletes inter_team_trade_group if there was only on inter_team_trade in it' do
    expect { service }
      .to change { InterTeamTradeGroup.count }.from(1).to(0)
      .and change { InterTeamTrade.count }.from(1).to(0)
  end

  it 'removes the inter_team_trade but does not delete the inter_team_trade_group if there is more than one' do
    create :inter_team_trade, inter_team_trade_group: inter_team_trade_group

    expect { service }
      .to change { InterTeamTradeGroup.count }.by(0)
      .and change { InterTeamTrade.count }.from(2).to(1)
  end

  it 'fails if the user is not the fpl_team owner' do
    fpl_team.update(owner: create(:user))

    expect { subject }
      .to change { InterTeamTrade.count }.by(0)

    expect(subject.errors.full_messages).to contain_exactly('You are not authorised to perform this action')
  end

  it 'fails if the round is no longer current' do
    round.update(data_checked: true)

    expect { subject }
      .to change { InterTeamTrade.count }.by(0)

    expect(subject.errors.full_messages).to contain_exactly('This trade is not from the current round')
  end

  it 'fails if the deadline_time has passed' do
    round.update(deadline_time: 1.minute.ago)

    expect { subject }
      .to change { InterTeamTrade.count }.by(0)

    expect(subject.errors.full_messages).to contain_exactly('The trade window is now closed')
  end

  it 'fails if the inter_team_trade_group is not pending' do
    inter_team_trade_group.update(status: 'approved')

    expect { subject }
      .to change { InterTeamTrade.count }.by(0)

    expect(service.errors.full_messages).to contain_exactly('Changes can no longer be made to the proposed trade')
  end
end
