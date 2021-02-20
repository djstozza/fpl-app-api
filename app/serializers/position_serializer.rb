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
class PositionSerializer < BaseSerializer
  ATTRS = %w[
    id
    singular_name
    singular_name_short
  ].freeze

  VERBOSE_ATTRS = %w[
    plural_name
    plural_name_short
    squad_select
    squad_min_play
    squad_max_play
  ]

  def serializable_hash(*)
    attributes.slice(*attrs)
  end

  private

  def attrs
    includes[:verbose] ? ATTRS + VERBOSE_ATTRS : ATTRS
  end
end
