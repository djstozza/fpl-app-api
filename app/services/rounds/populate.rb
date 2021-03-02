# Populate rounds service
class Rounds::Populate < BasePopulateService
  def call
    response.each do |round_json|
      round = Round.find_or_create_by(external_id: round_json['id'])

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
  end

  private

  def response
    @response ||= ::HTTParty.get(bootstrap_static_url)['events']
  end
end
