require 'rails_helper'

RSpec.describe Rounds::RecurringWaiverDeadlineCheckingJob do
  include ActiveSupport::Testing::TimeHelpers
  let(:round) { create :round, :current }
  let(:fpl_team_list) { create :fpl_team_list, round: round }
  let!(:waiver_pick) { create :waiver_pick, fpl_team_list: fpl_team_list }

  it 'triggers the waiver processing job' do
    travel_to round.waiver_deadline.beginning_of_day do
      expect { described_class.perform_now }
        .to enqueue_job(WaiverPicks::ProcessingJob).at(round.waiver_deadline).with(round.id)
    end
  end

  it 'does not trigger the waiver processing job if the date is not correct' do
    travel_to round.waiver_deadline - 3.days do
      expect { described_class.perform_now }
        .not_to enqueue_job(WaiverPicks::ProcessingJob)
    end
  end

  it 'does not trigger the waiver processing job if there are no pending waiver picks' do
    waiver_pick.update(status: 'approved')

    travel_to round.waiver_deadline.beginning_of_day do
      expect { described_class.perform_now }
        .not_to enqueue_job(WaiverPicks::ProcessingJob)
    end
  end

  it 'does not trigger the waiver processing job if the round is not current' do
    round.update(data_checked: true)

    travel_to round.waiver_deadline.beginning_of_day do
      expect { described_class.perform_now }
        .not_to enqueue_job(WaiverPicks::ProcessingJob)
    end
  end
end
