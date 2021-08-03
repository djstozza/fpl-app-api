# == Schema Information
#
# Table name: fpl_team_lists
#
#  id              :bigint           not null, primary key
#  cumulative_rank :integer
#  round_rank      :integer
#  total_score     :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  fpl_team_id     :bigint
#  round_id        :bigint
#
# Indexes
#
#  index_fpl_team_lists_on_fpl_team_id               (fpl_team_id)
#  index_fpl_team_lists_on_fpl_team_id_and_round_id  (fpl_team_id,round_id) UNIQUE
#  index_fpl_team_lists_on_round_id                  (round_id)
#
require 'rails_helper'

RSpec.describe FplTeamList, type: :model do
  it 'has a valid factory' do
    expect(build(:fpl_team_list)).to be_valid
  end

  it 'validates round and fpl_team uniqueness' do
    fpl_team_list = create :fpl_team_list

    expect(create(:fpl_team_list, fpl_team: fpl_team_list.fpl_team)).to be_valid
    expect(create(:fpl_team_list, round: fpl_team_list.round)).to be_valid
    expect(build(:fpl_team_list, round: fpl_team_list.round, fpl_team: fpl_team_list.fpl_team)).not_to be_valid
  end
end
