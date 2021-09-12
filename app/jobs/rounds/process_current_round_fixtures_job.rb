# Populate fixtures for the current round and broadcast
class Rounds::ProcessCurrentRoundFixturesJob < ApplicationJob
  def perform
    current_round = Round.find_by(is_current: true)
    return unless current_round

    Fixtures::Populate.call(current_round)

    ActionCable
      .server
      .broadcast("round_#{current_round.id}", { updatedAt: Time.current.to_i })
  end
end
