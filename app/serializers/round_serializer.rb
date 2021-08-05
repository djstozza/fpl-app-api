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
#  mini_draft                :boolean          default(FALSE), not null
#  name                      :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  external_id               :integer
#
class RoundSerializer < BaseSerializer
  ATTRS = %w[
    id
    name
    mini_draft
    deadline_time
    deadline_time_epoch
    finished
    data_checked
    is_previous
    is_current
    is_next
  ].freeze

  def serializable_hash(*)
    attributes.slice(*ATTRS).tap do |attrs|
      attrs[:current] = current?
      attrs[:waiver_deadline] = waiver_deadline
    end
  end
end
