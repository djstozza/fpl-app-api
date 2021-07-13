# == Schema Information
#
# Table name: mini_draft_picks
#
#  id            :bigint           not null, primary key
#  passed        :boolean          default(FALSE), not null
#  pick_number   :integer
#  season        :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  fpl_team_id   :bigint
#  in_player_id  :bigint
#  league_id     :bigint
#  out_player_id :bigint
#
# Indexes
#
#  index_mini_draft_picks_on_fpl_team_id    (fpl_team_id)
#  index_mini_draft_picks_on_in_player_id   (in_player_id)
#  index_mini_draft_picks_on_league_id      (league_id)
#  index_mini_draft_picks_on_out_player_id  (out_player_id)
#
# Foreign Keys
#
#  fk_rails_...  (in_player_id => players.id)
#  fk_rails_...  (out_player_id => players.id)
#
require 'rails_helper'

RSpec.describe MiniDraftPick, type: :model do
  it 'has a valid factory' do
    expect(build :mini_draft_pick).to be_valid
    expect(build :mini_draft_pick, :passed).to be_valid
  end

  it 'validates pick number uniquness' do
    mini_draft_pick = create :mini_draft_pick

    expect { create :mini_draft_pick, pick_number: mini_draft_pick.pick_number, league: mini_draft_pick.league }
      .to raise_error(ActiveRecord::RecordInvalid, /Pick number has already been taken/)


    expect(create :mini_draft_pick, :winter, pick_number: mini_draft_pick.pick_number, league: mini_draft_pick.league)
      .to be_valid
  end

  it 'validates the presence of an out_player and in_player if passed = false' do
    expect { create :mini_draft_pick, out_player: nil, in_player: nil }
      .to raise_error(ActiveRecord::RecordInvalid, /In player can't be blank, Out player can't be blank/)

    expect { create :mini_draft_pick, in_player: nil }
      .to raise_error(ActiveRecord::RecordInvalid, /In player can't be blank/)

    expect { create :mini_draft_pick, out_player: nil }
      .to raise_error(ActiveRecord::RecordInvalid, /Out player can't be blank/)
  end

  it 'validates the absence of passed if out_player and in_player are present' do
    expect { create :mini_draft_pick, passed: true }
      .to raise_error(ActiveRecord::RecordInvalid, /In player must be blank, Out player must be blank/)
  end
end
