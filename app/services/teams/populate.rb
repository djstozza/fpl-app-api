# Populate teams service
class Teams::Populate < BasePopulateService
  def call
    response.each do |team_json|
      team = Team.find_or_create_by(external_id: team_json['id'])

      team.update!(
        name: team_json['name'],
        code: team_json['code'],
        short_name: team_json['short_name'],
        strength: team_json['strength'],
        strength_overall_home: team_json['strength_overall_home'],
        strength_overall_away: team_json['strength_overall_away'],
        strength_attack_home: team_json['strength_attack_home'],
        strength_attack_away: team_json['strength_attack_away'],
        strength_defence_home: team_json['strength_defence_home'],
        strength_defence_away: team_json['strength_defence_away'],
      )
    end
  end

  private

  def response
    @response ||= ::HTTParty.get(bootstrap_static_url)['teams']
  end
end
