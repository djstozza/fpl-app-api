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
      let!(:round_1) do
        create(
          :round,
          name: 'Gameweek 1',
          deadline_time: '2021-08-13T17:30:00Z',
          finished: true,
          data_checked: true,
          deadline_time_epoch: 1_599_904_800,
          deadline_time_game_offset: 0,
          is_previous: false,
          is_current: false,
          is_next: false,
          external_id: 1
        )
      end
      let!(:round_2) do
        create(
          :round,
          name: 'Gameweek 2',
          deadline_time: '2021-08-21T10:00:00Z',
          finished: false,
          data_checked: false,
          deadline_time_epoch: 1_600_509_600,
          deadline_time_game_offset: 0,
          is_previous: false,
          is_current: true,
          is_next: false,
          external_id: 2
        )
      end
      let!(:round_3) do
        create(
          :round,
          name: 'Gameweek 3',
          deadline_time: '2021-08-28T10:00:00Z',
          finished: true,
          data_checked: true,
          deadline_time_epoch: 1_601_114_400,
          deadline_time_game_offset: 0,
          is_previous: false,
          is_current: false,
          is_next: true,
          external_id: 3
        )
      end

      it 'does not update rounds that have finished and are no longer current' do
        travel_to Time.zone.parse(round_1.deadline_time).beginning_of_year do
          expect { described_class.call }
            .to change { round_3.reload.is_next }.from(true).to(false)
            .and change { round_3.reload.is_current }.from(false).to(true)
            .and change { round_2.reload.is_current }.from(true).to(false)
            .and change { round_2.reload.data_checked }.from(false).to(true)
            .and change { round_2.reload.finished }.from(false).to(true)
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
