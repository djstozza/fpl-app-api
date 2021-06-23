require 'rails_helper'

RSpec.describe FplTeams::ProcessInitialLineup, type: :service do
  let(:fpl_team) { create :fpl_team }
  let!(:round) { create :round }
  let!(:current_round) { create :round, :current }
  subject(:service) { described_class.call(fpl_team) }
  let!(:forward1) { create :player, :forward, ict_index: 30 }
  let!(:forward2) { create :player, :forward, ict_index: 4 }
  let!(:forward3) { create :player, :forward, ict_index: 300 }
  let!(:midfielder1) { create :player, :midfielder, ict_index: 100 }
  let!(:midfielder2) { create :player, :midfielder, ict_index: 50 }
  let!(:midfielder3) { create :player, :midfielder, ict_index: 200 }
  let!(:midfielder4) { create :player, :midfielder, ict_index: 7 }
  let!(:midfielder5) { create :player, :midfielder, ict_index: 10 }
  let!(:defender1) { create :player, :defender, ict_index: 70 }
  let!(:defender2) { create :player, :defender, ict_index: 100 }
  let!(:defender3) { create :player, :defender, ict_index: 1 }
  let!(:defender4) { create :player, :defender, ict_index: 19 }
  let!(:defender5) { create :player, :defender, ict_index: 20 }
  let!(:goalkeeper1) { create :player, :goalkeeper, ict_index: 12 }
  let!(:goalkeeper2) { create :player, :goalkeeper, ict_index: 13 }

  before do
    fpl_team.players += Player.all
  end

  it 'populates the first lineup for an fpl_team for the current round' do
    expect { service }
      .to change { ListPosition.count }.from(0).to(15)

    fpl_team_list = service.fpl_team_list
    expect(fpl_team_list.round).to eq(current_round)
    expect(fpl_team_list.fpl_team).to eq(fpl_team)

    expect(fpl_team_list.list_positions.substitute_gkp)
      .to contain_exactly(have_attributes(player: goalkeeper1))

    expect(fpl_team_list.list_positions.starting).to contain_exactly(
      have_attributes(player: forward3),
      have_attributes(player: forward1),
      have_attributes(player: midfielder1),
      have_attributes(player: midfielder2),
      have_attributes(player: midfielder3),
      have_attributes(player: midfielder5),
      have_attributes(player: defender1),
      have_attributes(player: defender2),
      have_attributes(player: defender4),
      have_attributes(player: defender5),
      have_attributes(player: goalkeeper2),
    )

    expect(fpl_team_list.list_positions.substitute_1).to contain_exactly(
      have_attributes(player: midfielder4),
    )

    expect(fpl_team_list.list_positions.substitute_2).to contain_exactly(
      have_attributes(player: forward2),
    )

    expect(fpl_team_list.list_positions.substitute_3).to contain_exactly(
      have_attributes(player: defender3),
    )
  end

  it 'populates the initial lineup with the first round if there is no current round' do
    current_round.update(is_current: false)

    expect { service }
      .to change { ListPosition.count }.from(0).to(15)

    fpl_team_list = service.fpl_team_list
    expect(fpl_team_list.round).to eq(round)
    expect(fpl_team_list.fpl_team).to eq(fpl_team)
  end
end
