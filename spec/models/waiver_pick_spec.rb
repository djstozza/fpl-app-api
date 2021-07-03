# == Schema Information
#
# Table name: waiver_picks
#
#  id               :bigint           not null, primary key
#  pick_number      :integer          not null
#  status           :integer          default("pending"), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  fpl_team_list_id :bigint
#  in_player_id     :bigint
#  out_player_id    :bigint
#
# Indexes
#
#  index_waiver_picks_on_fpl_team_list_id  (fpl_team_list_id)
#  index_waiver_picks_on_in_player_id      (in_player_id)
#  index_waiver_picks_on_out_player_id     (out_player_id)
#
# Foreign Keys
#
#  fk_rails_...  (in_player_id => players.id)
#  fk_rails_...  (out_player_id => players.id)
#
require 'rails_helper'

RSpec.describe WaiverPick, type: :model do
  it 'has a valid factory' do
    expect(build :waiver_pick).to be_valid
    expect(build :waiver_pick, :pending).to be_valid
    expect(build :waiver_pick, :approved).to be_valid
    expect(build :waiver_pick, :declined).to be_valid
  end

  it 'validates pick_number uniqueness for an fpl_team_list' do
    waiver_pick = create(:waiver_pick)

    expect {
      create(:waiver_pick, pick_number: waiver_pick.pick_number, fpl_team_list: waiver_pick.fpl_team_list)
    }.to raise_error(ActiveRecord::RecordInvalid, /Pick number has already been taken/)

    expect(create :waiver_pick, pick_number: waiver_pick.pick_number).to be_valid
  end
end
