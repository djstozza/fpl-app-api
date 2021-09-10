# == Schema Information
#
# Table name: positions
#
#  id                  :bigint           not null, primary key
#  plural_name         :citext
#  plural_name_short   :citext
#  singular_name       :citext
#  singular_name_short :citext
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
class Position < ApplicationRecord
  validates :external_id, presence: true, uniqueness: true

  has_many :players
end
