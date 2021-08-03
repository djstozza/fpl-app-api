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
# Indexes
#
#  index_rounds_on_external_id  (external_id) UNIQUE
#
class Round < ApplicationRecord
  has_many :fixtures

  validates :external_id, presence: true, uniqueness: true

  def deadline_time_as_time
    deadline_time.is_a?(String) ? deadline_time.in_time_zone : deadline_time
  end

  def waiver_deadline
    deadline_time_as_time - 1.day
  end

  def current?
    return true if is_current && !data_checked
    return false unless is_next

    current_round = Round.find_by(is_current: true)
    is_next && (!current_round || current_round.data_checked)
  end

  class << self
    def current
      current_round = find_by(is_current: true)
      return current_round if current_round && !current_round.data_checked

      next_round = find_by(is_next: true)
      next_round if next_round && !next_round.data_checked
    end

    def summer_mini_draft_deadline
      @summer_mini_draft_deadline ||= Time.zone.parse("01/09/#{Round.first.deadline_time_as_time.year}")
    end

    def winter_mini_draft_deadline
      @winter_mini_draft_deadline ||= Time.zone.parse("01/02/#{(Round.first.deadline_time_as_time + 1.year).year}")
    end

    def mini_draft_deadline
      Time.current.year < winter_mini_draft_deadline.year ? summer_mini_draft_deadline : winter_mini_draft_deadline
    end
  end
end
