# == Schema Information
#
# Table name: rounds
#
#  id                        :bigint           not null, primary key
#  data_checked              :boolean
#  deadline_time             :string
#  deadline_time_epoch       :integer
#  deadline_time_game_offset :integer
#  finished                  :boolean
#  is_current                :boolean
#  is_next                   :boolean
#  is_previous               :boolean
#  name                      :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  external_id               :integer
#
require 'rails_helper'

RSpec.describe Round, type: :model do
  it 'has a valid factory' do
    expect(build(:round, :current)).to be_valid
    expect(build(:round, :next)).to be_valid
    expect(build(:round, :previous)).to be_valid
    expect(build(:round, :past)).to be_valid
    expect(build(:round, :future)).to be_valid
  end

  describe '#is_current?' do
    let!(:round) { create :round, :current }


    it 'is true if is_current = true and data_checked = false' do
      expect(round.is_current?).to eq(true)
    end

    it 'is false if is_current = true and data_checked = true' do
      round.update(data_checked: true)

      expect(round.is_current?).to eq(false)
    end

    it 'is false if is_current = false' do
      round.update(is_current: false)

      expect(round.is_current?).to eq(false)
    end

    it 'is true if is_next = true if no round with is_current = true or if it is data_checked' do
      next_round = create(:round, :next)

      expect(next_round.is_current?).to eq(false)

      round.update(data_checked: true)
      expect(next_round.is_current?).to eq(true)

      round.update(is_current: false, data_checked: false)
      expect(next_round.is_current?).to eq(true)
    end
  end
end
