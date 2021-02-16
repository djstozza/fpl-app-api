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
end
