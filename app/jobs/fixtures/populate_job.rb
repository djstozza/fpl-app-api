# Populate fixtures
class Fixtures::PopulateJob < ApplicationJob
  def perform
    Fixtures::Populate.call
  end
end
