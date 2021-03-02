require 'rails_helper'

RSpec.describe Teams::ProcessStats, type: :service do
  include StubRequestHelper

  describe '#call' do
    before do
      stub_bootstrap_static_request

      Rounds::Populate.call
      Teams::Populate.call

      stub_fixture_request

      Fixtures::Populate.call
    end

    it 'updates the details of each team', :no_transaction do
      described_class.call

      expect(team('Leicester').attributes).to include(
        'position' => 1,
        'form' => %w[W W],
        'wins' => 2,
        'losses' => 0,
        'draws' => 0,
        'goal_difference' => 5,
        'goals_for' => 7,
        'goals_against' => 2,
        'clean_sheets' => 1,
      )

      expect(team('Everton').attributes).to include(
        'position' => 2,
        'form' => %w[W W],
        'wins' => 2,
        'losses' => 0,
        'draws' => 0,
        'goal_difference' => 4,
        'goals_for' => 6,
        'goals_against' => 2,
        'clean_sheets' => 1,
      )

      expect(team('Arsenal').attributes).to include(
        'position' => 2,
        'form' => %w[W W],
        'wins' => 2,
        'losses' => 0,
        'draws' => 0,
        'goal_difference' => 4,
        'goals_for' => 5,
        'goals_against' => 1,
        'clean_sheets' => 1,
      )

      expect(team('Wolves').attributes).to include(
        'position' => 10,
        'form' => %w[W L],
        'wins' => 1,
        'losses' => 1,
        'draws' => 0,
        'goal_difference' => 0,
        'goals_for' => 3,
        'goals_against' => 3,
        'clean_sheets' => 1,
      )

      expect(team('West Brom').attributes).to include(
        'position' => 20,
        'form' => %w[L L],
        'wins' => 0,
        'losses' => 2,
        'draws' => 0,
        'goal_difference' => -6,
        'goals_for' => 2,
        'goals_against' => 8,
        'clean_sheets' => 0,
      )
    end
  end

  private

  def team(name)
    Team.find_by(name: name)
  end
end
