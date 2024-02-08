# == Schema Information
#
# Table name: leagues
#
#  id              :bigint           not null, primary key
#  active          :boolean          default(TRUE), not null
#  code            :string           not null
#  fpl_teams_count :integer          default(0), not null
#  name            :citext           not null
#  status          :integer          default("initialized"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  owner_id        :bigint
#
# Indexes
#
#  index_leagues_on_name      (name) UNIQUE
#  index_leagues_on_owner_id  (owner_id)
#
require 'rails_helper'

RSpec.describe League, type: :model do
  it 'has a valid factory' do
    expect(build(:league)).to be_valid
  end

  describe '.name' do
    it 'must be unique' do
      league = create(:league)

      expect { create(:league, name: league.name.upcase) }
        .to raise_error(ActiveRecord::RecordInvalid, /Name has already been taken/)
    end

    it 'must be present' do
      expect { create(:league, name: nil) }
        .to raise_error(ActiveRecord::RecordInvalid, /Name can't be blank/)
    end
  end

  describe '.code' do
    it 'must be present' do
      expect { create(:league, code: nil) }
        .to raise_error(ActiveRecord::RecordInvalid, /Code can't be blank/)
    end

    it "must be #{League::CODE_LENGTH} characters long" do
      code_length = League::CODE_LENGTH

      expect { create(:league, code: SecureRandom.alphanumeric(code_length - 1)) }
        .to raise_error(ActiveRecord::RecordInvalid, /Code is the wrong length \(should be #{code_length} characters\)/)

      expect { create(:league, code: SecureRandom.alphanumeric(code_length + 1)) }
        .to raise_error(ActiveRecord::RecordInvalid, /Code is the wrong length \(should be #{code_length} characters\)/)
    end
  end

  describe '#can_generate_draft_picks?' do
    it 'is true if the league fpl_team quota is reached and the league is initialized' do
      league = create(:league)

      League::MIN_FPL_TEAM_QUOTA.times do
        create(:fpl_team, league: league)
      end

      expect(league.can_generate_draft_picks?).to eq(true)
    end

    it 'is true if the league fpl_team quota is reached and the league status is generate_draft_picks' do
      league = create(:league, status: 'draft_picks_generated')

      League::MIN_FPL_TEAM_QUOTA.times do
        create(:fpl_team, league: league)
      end

      expect(league.can_generate_draft_picks?).to eq(true)
    end

    it 'is false if the league fpl_team quota is reached and the league status is incorrect' do
      league = create(:league, status: 'draft')

      League::MIN_FPL_TEAM_QUOTA.times do
        create(:fpl_team, league: league)
      end

      expect(league.can_generate_draft_picks?).to eq(false)

      league.update(status: 'live')
      expect(league.can_generate_draft_picks?).to eq(false)
    end

    it 'is false if the league does not have enough draft picks' do
      league = create(:league)

      (League::MIN_FPL_TEAM_QUOTA - 1).times do
        create(:fpl_team, league: league)
      end

      expect(league.can_generate_draft_picks?).to eq(false)
    end
  end
end
