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
  ].freeze

  def serializable_hash(*)
    attributes.slice(*attrs)
  end

  private

  def attrs
    includes[:verbose] ? ATTRS + VERBOSE_ATTRS : ATTRS
  end
end
