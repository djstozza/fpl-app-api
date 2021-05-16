# == Schema Information
#
# Table name: leagues
#
#  id         :bigint           not null, primary key
#  active     :boolean          default(TRUE), not null
#  code       :string           not null
#  name       :string           not null
#  status     :integer          default("initialized"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  owner_id   :bigint
#
# Indexes
#
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
end
