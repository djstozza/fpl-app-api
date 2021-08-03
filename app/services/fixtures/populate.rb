# Populate fixtures service
class Fixtures::Populate < BasePopulateService
  ATTRS = %w[
    kickoff_time
    code
    team_h_score
    team_a_score
    stats
    started
    finished
    provisional_start_time
    finished_provisional
    minutes
    team_h_difficulty
    team_a_difficulty
  ].freeze

  def initialize(round = nil)
    @round = round
  end

  def call
    response.each do |fixture_json|
      fixture = Fixture.find_or_initialize_by(external_id: fixture_json['id'])

      next if fixture_json['event'].blank?
      next if fixture.finished

      round ||= Round.find_by(external_id: fixture_json['event'])
      home_team = Team.find_by(external_id: fixture_json['team_h'])
      away_team = Team.find_by(external_id: fixture_json['team_a'])

      fixture.update!(
        round: round,
        home_team: home_team,
        away_team: away_team,
        **fixture_json.slice(*ATTRS),
      )
    end
  end

  private

  attr_accessor :round

  def response
    @response ||= ::HTTParty.get(fixtures_url(round&.external_id))
  end
end
