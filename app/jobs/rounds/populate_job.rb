# Populate rounds
class Rounds::PopulateJob < ApplicationJob
  def perform
    Rounds::Populate.call
  end
end
