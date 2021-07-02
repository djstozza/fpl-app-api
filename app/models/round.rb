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
class Round < ApplicationRecord
  has_many :fixtures

  def self.current
    current_round = find_by(is_current: true)
    return current_round if current_round && !current_round.data_checked

    next_round = find_by(is_next: true)
    next_round if next_round && !next_round.data_checked
  end

  def waiver_deadline_epoch
    deadline_time_epoch - 1.day.to_i
  end

  def waiver_deadline
    (deadline_time.kind_of?(String) ? Time.parse(deadline_time) : deadline_time) - 1.day
  end

  def is_current?
    return true if is_current && !data_checked
    return false unless is_next

    current_round = Round.find_by(is_current: true)
    is_next && (!current_round || current_round.data_checked)
  end

  validates :external_id, presence: true, uniqueness: true
end
