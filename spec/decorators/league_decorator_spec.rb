require 'rails_helper'

RSpec.describe LeagueDecorator, :no_transaction do
  include ActiveSupport::Testing::TimeHelpers

  subject(:decorated) { league.decorate }

  let!(:round) { create :round, :mini_draft }
  let(:league) { create :league }
  let!(:fpl_team1) { create :fpl_team, mini_draft_pick_number: 1, rank: 3, league: league }
  let!(:fpl_team2) { create :fpl_team, mini_draft_pick_number: 2, rank: 1, league: league }
  let!(:fpl_team3) { create :fpl_team, mini_draft_pick_number: 3, rank: 2, league: league }

  describe '#current_mini_draft_pick' do
    context 'when summer mini draft' do
      before { round.update(deadline_time: Round.summer_mini_draft_deadline + 1.week) }

      it 'returns the current_mini_draft_pick' do
        travel_to round.deadline_time_as_time.advance(days: -3) do
          current_mini_draft_pick(fpl_team1, 1, 'summer')

          create :mini_draft_pick, pick_number: 1, fpl_team: fpl_team1

          current_mini_draft_pick(fpl_team2, 2, 'summer')
        end
      end

      it 'returns nil if all fpl_teams have passed' do
        travel_to round.deadline_time_as_time.advance(days: -3) do
          create :mini_draft_pick, :passed, league: league, fpl_team: fpl_team1, pick_number: 1
          create :mini_draft_pick, :passed, league: league, fpl_team: fpl_team1, pick_number: 2
          create :mini_draft_pick, :passed, league: league, fpl_team: fpl_team2, pick_number: 3
          create :mini_draft_pick, :passed, league: league, fpl_team: fpl_team2, pick_number: 4
          create :mini_draft_pick, :passed, league: league, fpl_team: fpl_team3, pick_number: 5
          create :mini_draft_pick, :passed, league: league, fpl_team: fpl_team3, pick_number: 6

          expect(decorated.current_mini_draft_pick).to be_nil
        end
      end
    end

    context 'when winter mini draft' do
      before { round.update(deadline_time: Round.winter_mini_draft_deadline + 1.week) }

      it 'returns the current_mini_draft_pick' do
        travel_to round.deadline_time_as_time.advance(days: -3) do
          current_mini_draft_pick(fpl_team1, 1, 'winter')

          create :mini_draft_pick, :winter, pick_number: 1, fpl_team: fpl_team1

          current_mini_draft_pick(fpl_team3, 2, 'winter')
        end
      end

      it 'returns nil if all fpl_teams have passed' do
        travel_to round.deadline_time_as_time.advance(days: -3) do
          create :mini_draft_pick, :winter, :passed, league: league, fpl_team: fpl_team1, pick_number: 1
          create :mini_draft_pick, :winter, :passed, league: league, fpl_team: fpl_team1, pick_number: 2
          create :mini_draft_pick, :winter, :passed, league: league, fpl_team: fpl_team2, pick_number: 3
          create :mini_draft_pick, :winter, :passed, league: league, fpl_team: fpl_team2, pick_number: 4
          create :mini_draft_pick, :winter, :passed, league: league, fpl_team: fpl_team3, pick_number: 5
          create :mini_draft_pick, :winter, :passed, league: league, fpl_team: fpl_team3, pick_number: 6

          expect(decorated.current_mini_draft_pick).to be_nil
        end
      end
    end
  end

  describe '#next_draft_pick' do
    context 'when summer mini draft' do
      before { round.update(deadline_time: Round.summer_mini_draft_deadline.advance(weeks: 1)) }

      it 'skips teams with consecutive passes' do
        travel_to round.deadline_time_as_time.advance(days: -3) do
          create :mini_draft_pick, league: league, fpl_team: fpl_team1, pick_number: 1
          create :mini_draft_pick, :passed, league: league, fpl_team: fpl_team2, pick_number: 2
          create :mini_draft_pick, league: league, fpl_team: fpl_team3, pick_number: 3
          create :mini_draft_pick, league: league, fpl_team: fpl_team3, pick_number: 4
          create :mini_draft_pick, :passed, league: league, fpl_team: fpl_team2, pick_number: 5
          create :mini_draft_pick, league: league,  fpl_team: fpl_team1, pick_number: 6
          create :mini_draft_pick, league: league, fpl_team: fpl_team1, pick_number: 7

          expect(decorated.next_fpl_team).to eq(fpl_team3)
        end
      end
    end

    context 'when winter mini draft' do
      before { round.update(deadline_time: Round.winter_mini_draft_deadline.advance(weeks: 1)) }

      it 'skips teams with consecutive passes' do
        travel_to round.deadline_time_as_time.advance(days: -3) do
          create :mini_draft_pick, :winter, league: league, fpl_team: fpl_team1, pick_number: 1
          create :mini_draft_pick, :winter, :passed, league: league, fpl_team: fpl_team3, pick_number: 2
          create :mini_draft_pick, :winter, league: league, fpl_team: fpl_team2, pick_number: 3
          create :mini_draft_pick, :winter, league: league, fpl_team: fpl_team2, pick_number: 4
          create :mini_draft_pick, :winter, :passed, league: league, fpl_team: fpl_team3, pick_number: 5
          create :mini_draft_pick, :winter, league: league, fpl_team: fpl_team1, pick_number: 6
          create :mini_draft_pick, :winter, league: league, fpl_team: fpl_team1, pick_number: 7

          expect(decorated.next_fpl_team).to eq(fpl_team2)
        end
      end
    end
  end

  private

  def current_mini_draft_pick(fpl_team, pick_number, season)
    expect(decorated.current_mini_draft_pick).to have_attributes(
      fpl_team: fpl_team,
      pick_number: pick_number,
      passed: false,
      in_player: nil,
      out_player: nil,
      season: season,
    )
  end
end
