# Populate positions
class Positions::PopulateJob < ApplicationJob
  def perform
    Positions::Populate.call
  end
end
