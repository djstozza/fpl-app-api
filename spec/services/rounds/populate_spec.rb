require 'rails_helper'

RSpec.describe Rounds::Populate, type: :service do
  include ActiveSupport::Testing::TimeHelpers
  include StubRequestHelper

  describe '#call' do
    before { stub_bootstrap_static_request }

    it 'creates rounds' do
      expect { described_class.call }.to change(Round, :count).from(0).to(3)
      expect(Round.first.attributes).to include(
        'external_id' => 1,
        'name' => 'Gameweek 1',
        'finished' => true,
        'data_checked' => true,
        'is_previous' => false,
        'is_current' => false,
        'is_next' => false,
      )
    end

    describe 'existing rounds' do
      let!(:round_1) { create :round, :past, external_id: 1 }
      let!(:round_2) { create :round, :past, external_id: 2 }
      let!(:round_3) { create :round, :mini_draft, external_id: 3 }

      it 'only updates existing rounds that have not finished' do
        travel_to Time.current.beginning_of_year do
          expect { described_class.call }
            .to change { round_3.reload.data_checked }.from(false).to(true)
            .and not_change { round_2.reload.updated_at }
            .and not_change { round_1.reload.updated_at }
        end
      end
    end

    describe '#mini_draft_rounds' do
      let!(:round1) { create :round, deadline_time: Round.summer_mini_draft_deadline - 1.week, external_id: 100_000 }
      let!(:round2) { create :round, deadline_time: Round.summer_mini_draft_deadline + 1.week, external_id: 100_001 }
      let!(:round3) { create :round, deadline_time: Round.summer_mini_draft_deadline + 2.weeks, external_id: 100_002 }
      let!(:round4) { create :round, deadline_time: Round.winter_mini_draft_deadline - 1.week, external_id: 100_003 }
      let!(:round5) { create :round, deadline_time: Round.winter_mini_draft_deadline + 1.week, external_id: 100_004 }
      let!(:round6) { create :round, deadline_time: Round.winter_mini_draft_deadline + 2.weeks, external_id: 100_005 }

      it 'sets rounds with mini_draft = true if none are present' do
        described_class.call

        expect(round2.reload.mini_draft).to eq(true)
        expect(round5.reload.mini_draft).to eq(true)
      end
    end
  end
end
