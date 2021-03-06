# Populate fixtures
class Fixtures::PopulateJob < ApplicationJob
  def perform
    current_round = Round.find_by(is_current: true)
    return unless current_round

    Fixtures::Populate.call(current_round)
  end
end
