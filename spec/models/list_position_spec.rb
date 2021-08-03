# == Schema Information
#
# Table name: list_positions
#
#  id               :bigint           not null, primary key
#  role             :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  fpl_team_list_id :bigint
#  player_id        :bigint
#
# Indexes
#
#  index_list_positions_on_fpl_team_list_id                (fpl_team_list_id)
#  index_list_positions_on_player_id                       (player_id)
#  index_list_positions_on_player_id_and_fpl_team_list_id  (player_id,fpl_team_list_id) UNIQUE
#
require 'rails_helper'

RSpec.describe ListPosition, type: :model do
  it 'has a valid factory' do
    expect(build(:list_position, :starting, :forward)).to be_valid
    expect(build(:list_position, :starting, :midfielder)).to be_valid
    expect(build(:list_position, :starting, :defender)).to be_valid
    expect(build(:list_position, :starting, :goalkeeper)).to be_valid
    expect(build(:list_position, :substitute_1, :forward)).to be_valid
    expect(build(:list_position, :substitute_1, :midfielder)).to be_valid
    expect(build(:list_position, :substitute_1, :defender)).to be_valid
    expect(build(:list_position, :substitute_2, :forward)).to be_valid
    expect(build(:list_position, :substitute_2, :midfielder)).to be_valid
    expect(build(:list_position, :substitute_2, :defender)).to be_valid
    expect(build(:list_position, :substitute_3, :forward)).to be_valid
    expect(build(:list_position, :substitute_3, :midfielder)).to be_valid
    expect(build(:list_position, :substitute_3, :defender)).to be_valid
    expect(build(:list_position, :substitute_gkp)).to be_valid
  end

  describe '#valid_substitute_gkp' do
    it 'fails if the substitute_gkp is not a goalkeeper' do
      expect { create :list_position, role: 'substitute_gkp', player: create(:player, :forward) }
        .to raise_error(ActiveRecord::RecordInvalid, /Only a goalkeeper can be selected as a substitute goalkeeper/)

      expect { create :list_position, role: 'substitute_gkp', player: create(:player, :midfielder) }
        .to raise_error(ActiveRecord::RecordInvalid, /Only a goalkeeper can be selected as a substitute goalkeeper/)

      expect { create :list_position, role: 'substitute_gkp', player: create(:player, :defender) }
        .to raise_error(ActiveRecord::RecordInvalid, /Only a goalkeeper can be selected as a substitute goalkeeper/)
    end
  end

  describe '#valid_substitutes' do
    it 'fails if a goalkeeper is selected as substitute_1, substitute_2 or substitute_3' do
      expect { create :list_position, role: 'substitute_1', player: create(:player, :goalkeeper) }
        .to raise_error(ActiveRecord::RecordInvalid, /A goalkeeper can only be selected as a substitute goalkeeper/)

      expect { create :list_position, role: 'substitute_2', player: create(:player, :goalkeeper) }
        .to raise_error(ActiveRecord::RecordInvalid, /A goalkeeper can only be selected as a substitute goalkeeper/)

      expect { create :list_position, role: 'substitute_3', player: create(:player, :goalkeeper) }
        .to raise_error(ActiveRecord::RecordInvalid, /A goalkeeper can only be selected as a substitute goalkeeper/)
    end
  end
end
