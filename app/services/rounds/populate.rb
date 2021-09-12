# Populate rounds service
class Rounds::Populate < BasePopulateService
  ATTRS = %w[
    name
    deadline_time
    finished
    data_checked
    deadline_time_epoch
    deadline_time_game_offset
    is_previous
    is_current
    is_next
  ].freeze

  def call
    response.each do |round_json|
      round = Round.find_or_create_by(external_id: round_json['id'])

      new_attrs = round_json.slice(*ATTRS)

      next if round.attributes.slice(*ATTRS) == new_attrs

      round.update!(new_attrs)
    end

    mini_draft_rounds
  end

  private

  def response
    @response ||= ::HTTParty.get(bootstrap_static_url)['events']
  end

  def mini_draft_rounds
    return if Round.where(mini_draft: true).any?

    rounds = Round.order(:deadline_time)

    summer_mini_draft_round = rounds.where('deadline_time > ?', Round.summer_mini_draft_deadline).first
    summer_mini_draft_round&.update!(mini_draft: true)

    winter_mini_draft_round = rounds.where('deadline_time > ?', Round.winter_mini_draft_deadline).first
    winter_mini_draft_round&.update!(mini_draft: true)
  end
end
