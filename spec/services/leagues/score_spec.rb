require 'rails_helper'

RSpec.describe Leagues::Score, type: :service do
  subject(:service) { described_class.new(league).call }

  let(:league) { create :league }
  let(:round1) { create :round }
  let(:round2) { create :round, is_current: true }

  let(:fpl_team1) { create :fpl_team, league: league, rank: 4 }
  let(:fpl_team2) { create :fpl_team, league: league, rank: 2 }
  let(:fpl_team3) { create :fpl_team, league: league, rank: 1 }
  let(:fpl_team4) { create :fpl_team, league: league, rank: 3 }

  let!(:fpl_team_list1) { create :fpl_team_list, fpl_team: fpl_team1, round: round1, total_score: 30 }
  let!(:fpl_team_list2) { create :fpl_team_list, fpl_team: fpl_team1, round: round2, total_score: 50 }
  let!(:fpl_team_list3) { create :fpl_team_list, fpl_team: fpl_team2, round: round1, total_score: 37 }
  let!(:fpl_team_list4) { create :fpl_team_list, fpl_team: fpl_team2, round: round2, total_score: 45 }
  let!(:fpl_team_list5) { create :fpl_team_list, fpl_team: fpl_team3, round: round1, total_score: 38 }
  let!(:fpl_team_list6) { create :fpl_team_list, fpl_team: fpl_team3, round: round2, total_score: 52 }
  let!(:fpl_team_list7) { create :fpl_team_list, fpl_team: fpl_team4, round: round1, total_score: 36 }
  let!(:fpl_team_list8) { create :fpl_team_list, fpl_team: fpl_team4, round: round2, total_score: 46 }

  it 'ranks the fpl teams and fpl team lists' do
    allow_any_instance_of(FplTeamLists::Score).to receive(:call)

    expect { service }
      .to change { fpl_team_list2.reload.round_rank }.from(nil).to(2)
      .and change { fpl_team_list4.reload.round_rank }.from(nil).to(4)
      .and change { fpl_team_list6.reload.round_rank }.from(nil).to(1)
      .and change { fpl_team_list8.reload.round_rank }.from(nil).to(3)
      .and change { fpl_team4.reload.rank }.from(3).to(2)
      .and not_change { fpl_team1.reload.rank } # still 4th
      .and not_change { fpl_team2.reload.rank } # still 2nd
      .and not_change { fpl_team3.reload.rank } # still 1st
      .and not_change { fpl_team_list1.reload.round_rank } # only fpl_team_lists from round 2 scored and ranked
      .and not_change { fpl_team_list3.reload.round_rank } # only fpl_team_lists from round 2 scored and ranked
      .and not_change { fpl_team_list5.reload.round_rank } # only fpl_team_lists from round 2 scored and ranked
      .and not_change { fpl_team_list7.reload.round_rank } # only fpl_team_lists from round 2 scored and ranked
  end
end
