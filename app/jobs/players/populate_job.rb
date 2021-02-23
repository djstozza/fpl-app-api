# Populate players
class Players::PopulateJob < ApplicationJob
  def perform
    Players::Populate.call
  end
end
