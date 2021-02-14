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
    plural_name
    plural_name_short
    squad_select
    squad_min_play
    squad_max_play
  ].freeze

  def serializable_hash(*)
    attributes.slice(*ATTRS)
  end
end
