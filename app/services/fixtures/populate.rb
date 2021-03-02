# Populate fixtures service
class Fixtures::Populate < BasePopulateService
  WINNING_POINTS = 3

  def call
    response.each do |fixture_json|
      fixture = Fixture.find_or_create_by(external_id: fixture_json['id'])

      next if fixture_json['event'].blank?

      round = Round.find_by(external_id: fixture_json['event'])
      home_team = Team.find_by(external_id: fixture_json['team_h'])
      away_team = Team.find_by(external_id: fixture_json['team_a'])

      fixture.update!(
        round: round,
        home_team: home_team,
        away_team: away_team,
        kickoff_time: fixture_json['kickoff_time'],
        code: fixture_json['code'],
        team_h_score: fixture_json['team_h_score'],
        team_a_score: fixture_json['team_a_score'],
        stats: fixture_json['stats'],
        started: fixture_json['started'],
        finished: fixture_json['finished'],
        provisional_start_time: fixture_json['provisional_start_time'],
        finished_provisional: fixture_json['finished_provisional'],
        minutes: fixture_json['minutes'],
        team_h_difficulty: fixture_json['team_h_difficulty'],
        team_a_difficulty: fixture_json['team_a_difficulty']
      )
    end
  end

  private

  def response
    @response ||= ::HTTParty.get(fixtures_url)
  end
end
