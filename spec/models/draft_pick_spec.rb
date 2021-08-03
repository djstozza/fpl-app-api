# == Schema Information
#
# Table name: draft_picks
#
#  id          :bigint           not null, primary key
#  mini_draft  :boolean          default(FALSE), not null
#  pick_number :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  fpl_team_id :bigint
#  league_id   :bigint
#  player_id   :bigint
#
# Indexes
#
#  index_draft_picks_on_fpl_team_id                (fpl_team_id)
#  index_draft_picks_on_league_id                  (league_id)
#  index_draft_picks_on_pick_number_and_league_id  (pick_number,league_id) UNIQUE
#  index_draft_picks_on_player_id                  (player_id)
#  index_draft_picks_on_player_id_and_league_id    (player_id,league_id) UNIQUE
#
require 'rails_helper'

RSpec.describe DraftPick, type: :model do
  let(:league) { create :league }

  it 'has a valid factory' do
    expect(build(:draft_pick)).to be_valid
    expect(build(:draft_pick, :mini_draft)).to be_valid
    expect(build(:draft_pick, :initialized)).to be_valid
  end

  it 'validates pick_number uniqueness within an fpl_team' do
    draft_pick = create(:draft_pick)
    fpl_team = create(:fpl_team, league: draft_pick.league)

    expect { create(:draft_pick, pick_number: draft_pick.pick_number, fpl_team: fpl_team) }
      .to raise_error(ActiveRecord::RecordInvalid, /Pick number has already been taken/)

    expect(create(:draft_pick, pick_number: draft_pick.pick_number)).to be_valid
  end

  it 'validates player uniquness within a league' do
    draft_pick = create(:draft_pick)
    fpl_team = create(:fpl_team, league: draft_pick.league)

    expect { create(:draft_pick, player: draft_pick.player, fpl_team: fpl_team) }
      .to raise_error(ActiveRecord::RecordInvalid, /Player has already been taken/)

    expect(create(:draft_pick, player: draft_pick.player)).to be_valid
  end

  describe '#player_pick_or_mini_draft' do
    it 'fails if there is no player and mini_draft = false' do
      draft_pick = create(:draft_pick, :initialized)

      expect { draft_pick.update!(player: nil, mini_draft: false) }
        .to raise_error(ActiveRecord::RecordInvalid, /Either select a player or a mini draft pick number/)
    end

    it 'fails if a player has been selected and mini_draft = true' do
      draft_pick = create(:draft_pick, :initialized)

      expect { draft_pick.update!(player: create(:player), mini_draft: true) }
        .to raise_error(ActiveRecord::RecordInvalid, /Either select a player or a mini draft pick/)
    end
  end

  describe '#fpl_team_in_league' do
    it 'fails if fpl_team is not in the league' do
      league = create(:league)

      expect { create(:draft_pick, league: league) }
        .to raise_error(ActiveRecord::RecordInvalid, /Fpl team must be in league/)
    end
  end
end
