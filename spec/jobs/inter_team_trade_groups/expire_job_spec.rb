require 'rails_helper'

RSpec.describe InterTeamTradeGroups::ExpireJob do
  let(:round) { create :round, :current, deadline_time: Time.current }
  let(:fpl_team_list) { create :fpl_team_list, round: round }
  let!(:inter_team_trade_group) { create :inter_team_trade_group, out_fpl_team_list: fpl_team_list }

  it 'expires pending inter team trade groups' do
    expect { described_class.perform_now(round.id) }
      .to change { inter_team_trade_group.reload.status }.from('pending').to('expired')
  end

  it 'returns if the round is not current' do
    round.update(data_checked: true)

    expect { described_class.perform_now(round.id) }
      .not_to change { inter_team_trade_group.reload.status }
  end

  it 'returns if the deadline time has not passed' do
    round.update(deadline_time: 2.days.from_now)

    expect { described_class.perform_now(round.id) }
      .not_to change { inter_team_trade_group.reload.status }
  end
end
