require 'rails_helper'

RSpec.describe MiniDraftPicks::Pass, :no_transaction, type: :service do
  include ActiveSupport::Testing::TimeHelpers

  subject(:service) { described_class.call(data, fpl_team_list, user) }

  let(:user) { create :user }
  let(:round) { create :round, :mini_draft }
  let(:league) { create :league }
  let!(:fpl_team1) { create :fpl_team, league: league, mini_draft_pick_number: 1, rank: 4, owner: user }
  let!(:fpl_team2) { create :fpl_team, league: league, mini_draft_pick_number: 2, rank: 1 }
  let!(:fpl_team3) { create :fpl_team, league: league, mini_draft_pick_number: 3, rank: 2 }
  let!(:fpl_team4) { create :fpl_team, league: league, mini_draft_pick_number: 4, rank: 3 }

  let(:fpl_team_list) { create :fpl_team_list, fpl_team: fpl_team1, round: round }

  let(:data) do
    { passed: true }
  end

  shared_examples 'invalid' do
    it 'fails if the round is not current' do
      round.update(is_current: false)

      travel_to round.deadline_time_as_time - 3.days do
        expect { service }
          .to not_change { MiniDraftPick.count }
          .and enqueue_job(MiniDraftPicks::BroadcastJob).exactly(0).times

        expect(service.errors.full_messages).to contain_exactly('The round is not current')
      end
    end

    it 'fails if the mini_draft is closed' do
      travel_to round.deadline_time_as_time - 23.hours do
        expect { service }
          .to not_change { MiniDraftPick.count }

        expect(service.errors.full_messages).to contain_exactly('The mini draft is now closed')
      end
    end

    it 'fails if round.mini_draft = false' do
      round.update(mini_draft: false)

      travel_to round.deadline_time_as_time - 3.days do
        expect { service }
          .to not_change { MiniDraftPick.count }
          .and enqueue_job(MiniDraftPicks::BroadcastJob).exactly(0).times

        expect(service.errors.full_messages).to contain_exactly('The mini draft is not active')
      end
    end

    it 'fails if the mini_draft_deadline has not passed' do
      travel_to round.deadline_time_as_time - 2.weeks do
        expect { service }
          .to not_change { MiniDraftPick.count }
          .and enqueue_job(MiniDraftPicks::BroadcastJob).exactly(0).times

        expect(service.errors).to contain_exactly('The mini draft is not open yet')
      end
    end

    it 'fails if the mini_draft_pick is made out of turn' do
      travel_to round.deadline_time_as_time - 3.days do
        create :mini_draft_pick, season: season, pick_number: 1, fpl_team: fpl_team1

        expect { subject }
          .to not_change { MiniDraftPick.count }
          .and enqueue_job(MiniDraftPicks::BroadcastJob).exactly(0).times

        expect(service.errors.full_messages).to contain_exactly(
          'It is not your turn to make a mini draft pick'
        )
      end
    end

    it 'fails if passed is not true' do
      data[:passed] = nil

      travel_to round.deadline_time_as_time - 3.days do
        expect { service }
          .to not_change { MiniDraftPick.count }
          .and enqueue_job(MiniDraftPicks::BroadcastJob).exactly(0).times

        expect(service.errors.full_messages).to contain_exactly('Passed is required')
      end
    end
  end

  context 'when summer mini draft' do
    before { round.update(deadline_time: Round.summer_mini_draft_deadline + 1.week) }

    it 'passes the mini draft pick and updates the next_fpl_team' do
      travel_to round.deadline_time_as_time - 3.days do
        expect { service }
          .to change(MiniDraftPick, :count).from(0).to(1)
          .and enqueue_job(MiniDraftPicks::BroadcastJob).with(MiniDraftPick.find_by(pick_number: 1))

        expect(MiniDraftPick.first).to have_attributes(
          fpl_team: fpl_team1,
          passed: true,
          in_player: nil,
          out_player: nil,
        )

        expect(current_mini_draft_pick).to have_attributes(
          pick_number: 2,
          fpl_team: fpl_team2,
          season: season,
        )
      end
    end

    it 'snakes the next fpl_team (bottom)' do
      travel_to round.deadline_time_as_time - 3.days do
        create(:mini_draft_pick, pick_number: 1, fpl_team: fpl_team1)
        create(:mini_draft_pick, pick_number: 2, fpl_team: fpl_team2)
        create(:mini_draft_pick, pick_number: 3, fpl_team: fpl_team3)
        create(:mini_draft_pick, pick_number: 4, fpl_team: fpl_team4)
        create(:mini_draft_pick, pick_number: 5, fpl_team: fpl_team4)
        create(:mini_draft_pick, pick_number: 6, fpl_team: fpl_team3)
        create(:mini_draft_pick, pick_number: 7, fpl_team: fpl_team2)

        expect { service }
          .to change(MiniDraftPick, :count).from(7).to(8)
          .and enqueue_job(MiniDraftPicks::BroadcastJob).with(MiniDraftPick.find_by(pick_number: 8))

        expect(current_mini_draft_pick).to have_attributes(
          pick_number: 9,
          fpl_team: fpl_team1,
          season: season,
        )
      end
    end

    it 'snakes the next fpl_team (top)' do
      travel_to round.deadline_time_as_time - 3.days do
        fpl_team_list.update(fpl_team: fpl_team4)
        fpl_team1.update(owner: create(:user))
        fpl_team4.update(owner: user)

        create(:mini_draft_pick, pick_number: 1, fpl_team: fpl_team1)
        create(:mini_draft_pick, pick_number: 2, fpl_team: fpl_team2)
        create(:mini_draft_pick, pick_number: 3, fpl_team: fpl_team3)

        expect { service }
          .to change(MiniDraftPick, :count).from(3).to(4)
          .and enqueue_job(MiniDraftPicks::BroadcastJob).with(MiniDraftPick.find_by(pick_number: 4))

        expect(current_mini_draft_pick).to have_attributes(
          pick_number: 5,
          fpl_team: fpl_team4,
          season: season,
        )
      end
    end

    it 'skips fpl_teams if they have consecutive passes' do
      travel_to round.deadline_time_as_time - 3.days do
        create(:mini_draft_pick, pick_number: 1, fpl_team: fpl_team1)
        create(:mini_draft_pick, :passed, pick_number: 2, fpl_team: fpl_team2)
        create(:mini_draft_pick, :passed, pick_number: 3, fpl_team: fpl_team3)
        create(:mini_draft_pick, pick_number: 4, fpl_team: fpl_team4)
        create(:mini_draft_pick, pick_number: 5, fpl_team: fpl_team4)
        create(:mini_draft_pick, :passed, pick_number: 6, fpl_team: fpl_team3)
        create(:mini_draft_pick, :passed, pick_number: 7, fpl_team: fpl_team2)
        create(:mini_draft_pick, pick_number: 8, fpl_team: fpl_team1)

        expect { service }
          .to change(MiniDraftPick, :count).from(8).to(9)
          .and enqueue_job(MiniDraftPicks::BroadcastJob).with(MiniDraftPick.find_by(pick_number: 9))

        expect(current_mini_draft_pick).to have_attributes(
          pick_number: 12, # Skips pick numbers 10 and 11 since fpl_team2 and fpl_team3 passed
          fpl_team: fpl_team4,
          season: season,
        )
      end
    end

    include_examples 'invalid'
  end

  context 'when winter mini draft' do
    before { round.update(deadline_time: Round.winter_mini_draft_deadline + 1.week) }

    it 'passes the mini draft pick and updates the next_fpl_team' do
      data[:passed] = true
      data[:in_player_id] = nil

      travel_to round.deadline_time_as_time - 3.days do
        expect { service }
          .to change(MiniDraftPick, :count).from(0).to(1)
          .and enqueue_job(MiniDraftPicks::BroadcastJob).with(MiniDraftPick.find_by(pick_number: 1))

        expect(MiniDraftPick.first).to have_attributes(
          fpl_team: fpl_team1,
          passed: true,
          in_player: nil,
          out_player: nil,
        )

        expect(current_mini_draft_pick).to have_attributes(
          pick_number: 2,
          fpl_team: fpl_team4,
          season: season,
        )
      end
    end

    it 'snakes the next fpl_team (bottom)' do
      travel_to round.deadline_time_as_time - 3.days do
        create(:mini_draft_pick, :winter, pick_number: 1, fpl_team: fpl_team1)
        create(:mini_draft_pick, :winter, pick_number: 2, fpl_team: fpl_team4)
        create(:mini_draft_pick, :winter, pick_number: 3, fpl_team: fpl_team3)
        create(:mini_draft_pick, :winter, pick_number: 4, fpl_team: fpl_team2)
        create(:mini_draft_pick, :winter, pick_number: 5, fpl_team: fpl_team2)
        create(:mini_draft_pick, :winter, pick_number: 6, fpl_team: fpl_team3)
        create(:mini_draft_pick, :winter, pick_number: 7, fpl_team: fpl_team4)

        expect { service }
          .to change(MiniDraftPick, :count).from(7).to(8)
          .and enqueue_job(MiniDraftPicks::BroadcastJob).with(MiniDraftPick.find_by(pick_number: 8))

        expect(current_mini_draft_pick).to have_attributes(
          pick_number: 9,
          fpl_team: fpl_team1,
          season: season,
        )
      end
    end

    it 'snakes the next fpl_team (top)' do
      travel_to round.deadline_time_as_time - 3.days do
        fpl_team_list.update(fpl_team: fpl_team2)
        fpl_team1.update(owner: create(:user))
        fpl_team2.update(owner: user)

        create(:mini_draft_pick, :winter, pick_number: 1, fpl_team: fpl_team1)
        create(:mini_draft_pick, :winter, pick_number: 2, fpl_team: fpl_team4)
        create(:mini_draft_pick, :winter, pick_number: 3, fpl_team: fpl_team3)

        expect { service }
          .to change(MiniDraftPick, :count).from(3).to(4)
          .and enqueue_job(MiniDraftPicks::BroadcastJob).with(MiniDraftPick.find_by(pick_number: 4))

        expect(current_mini_draft_pick).to have_attributes(
          pick_number: 5,
          fpl_team: fpl_team2,
          season: season,
        )
      end
    end

    it 'skips fpl_teams if they have consecutive passes' do
      travel_to round.deadline_time_as_time - 3.days do
        create(:mini_draft_pick, :winter, pick_number: 1, fpl_team: fpl_team1)
        create(:mini_draft_pick, :winter, :passed, pick_number: 2, fpl_team: fpl_team4)
        create(:mini_draft_pick, :winter, :passed, pick_number: 3, fpl_team: fpl_team3)
        create(:mini_draft_pick, :winter, pick_number: 4, fpl_team: fpl_team2)
        create(:mini_draft_pick, :winter, pick_number: 5, fpl_team: fpl_team2)
        create(:mini_draft_pick, :winter, :passed, pick_number: 6, fpl_team: fpl_team3)
        create(:mini_draft_pick, :winter, :passed, pick_number: 7, fpl_team: fpl_team4)
        create(:mini_draft_pick, :winter, pick_number: 8, fpl_team: fpl_team1)

        expect { service }
          .to change(MiniDraftPick, :count).from(8).to(9)
          .and enqueue_job(MiniDraftPicks::BroadcastJob).with(MiniDraftPick.find_by(pick_number: 9))

        expect(current_mini_draft_pick).to have_attributes(
          pick_number: 12, # Skips pick numbers 10 and 11 since fpl_team2 and fpl_team3 passed
          fpl_team: fpl_team2,
          season: season,
        )
      end
    end

    include_examples 'invalid'
  end

  private

  def current_mini_draft_pick
    LeagueDecorator.new(league).current_mini_draft_pick
  end

  def season
    round.deadline_time_as_time > Round.winter_mini_draft_deadline ? 'winter' : 'summer'
  end
end
