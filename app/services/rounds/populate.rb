# Populate rounds service
class Rounds::Populate < BasePopulateService
  def call
    response.each do |round_json|
      round = Round.find_or_create_by(external_id: round_json['id'])

      next if round.data_checked && round.finished

      update_round(round, round_json)
    end

    mini_draft_rounds
  end

  private

  def response
    @response ||= ::HTTParty.get(bootstrap_static_url)['events']
  end

  def update_round(round, round_json)
    round.update!(
      name: round_json['name'],
      deadline_time: round_json['deadline_time'],
      finished: round_json['finished'],
      data_checked: round_json['data_checked'],
      deadline_time_epoch: round_json['deadline_time_epoch'],
      deadline_time_game_offset: round_json['deadline_time_game_offset'],
      is_previous: round_json['is_previous'],
      is_current: round_json['is_current'],
      is_next: round_json['is_next'],
    )
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
