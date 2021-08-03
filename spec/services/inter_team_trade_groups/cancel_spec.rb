require 'rails_helper'

RSpec.describe InterTeamTradeGroups::Cancel, type: :service do
  subject(:service) { described_class.call(inter_team_trade_group, user) }

  let(:round) { create :round, :current }
  let(:user) { create :user }
  let(:fpl_team) { create :fpl_team, owner: user }
  let(:fpl_team_list1) { create :fpl_team_list, fpl_team: fpl_team, round: round }
  let(:fpl_team_list2) { create :fpl_team_list, round: round }

  let!(:inter_team_trade_group) do
    create(
      :inter_team_trade_group,
      out_fpl_team_list: fpl_team_list1,
      in_fpl_team_list: fpl_team_list2,
    )
  end

  it 'can cancel pending inter_team_trade_groups' do
    expect { service }
      .to change { inter_team_trade_group.reload.status }.from('pending').to('cancelled')
  end

  it 'can cancel submitted inter_team_trade_groups' do
    inter_team_trade_group.update(status: 'submitted')

    expect { service }
      .to change { inter_team_trade_group.reload.status }.from('submitted').to('cancelled')
  end

  it 'fails if the user is not the fpl_team owner' do
    fpl_team.update(owner: create(:user))

    expect { subject }
      .to not_change { inter_team_trade_group.reload.updated_at }

    expect(subject.errors.full_messages).to contain_exactly('You are not authorised to perform this action')
  end

  it 'fails if the round is no longer current' do
    round.update(data_checked: true)

    expect { subject }
      .to not_change { inter_team_trade_group.reload.updated_at }

    expect(subject.errors.full_messages).to contain_exactly('This trade is not from the current round')
  end

  it 'fails if the deadline_time has passed' do
    round.update(deadline_time: 1.minute.ago)

    expect { subject }
      .to not_change { inter_team_trade_group.reload.updated_at }

    expect(subject.errors.full_messages).to contain_exactly('The trade window is now closed')
  end

  it 'fails if the inter_team_trade_group is not submitted' do
    inter_team_trade_group.update(status: 'approved')

    expect { subject }
      .to not_change { inter_team_trade_group.reload.updated_at }

    expect(service.errors.full_messages)
      .to contain_exactly('You cannot cancel this trade proposal, as it has already been processed')
  end
end
