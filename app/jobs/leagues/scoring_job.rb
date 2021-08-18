class Leagues::ScoringJob < ApplicationJob
  def perform
    League.live.each { |league| Leagues::Score.new(league).call }
  end
end
