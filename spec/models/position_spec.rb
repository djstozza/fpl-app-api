# == Schema Information
#
# Table name: positions
#
#  id                  :bigint           not null, primary key
#  plural_name         :string
#  plural_name_short   :string
#  singular_name       :string
#  singular_name_short :string
#  squad_max_play      :integer
#  squad_min_play      :integer
#  squad_select        :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  external_id         :integer
#
# Indexes
#
#  index_positions_on_external_id  (external_id) UNIQUE
#
require 'rails_helper'

RSpec.describe Position, type: :model do
  it 'has a valid factory' do
    expect(build(:position, :forward)).to be_valid
  end
end
