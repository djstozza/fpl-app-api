require 'rails_helper'

RSpec.describe Rounds::Populate, type: :service do
  include StubRequestHelper

  describe '#call' do
    before { stub_bootstrap_static_request }

    it 'creates rounds' do
      expect { described_class.call }.to change { Round.count }.from(0).to(3)
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
      let!(:round_3) { create :round, :current, external_id: 3 }

      it 'only updates existing rounds that have not finished' do
        expect { described_class.call }
          .to change { round_3.reload.data_checked }.from(false).to(true)
          .and change { round_2.reload.updated_at }.by(0)
          .and change { round_1.reload.updated_at }.by(0)
      end
    end
  end
end
