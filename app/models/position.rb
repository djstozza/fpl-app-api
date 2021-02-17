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
class Position < ApplicationRecord
  validates :external_id, presence: true, uniqueness: true
end
