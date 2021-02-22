# Populate teams
class Teams::PopulateJob < ApplicationJob
  def perform
    Teams::Populate.call
  end
end
