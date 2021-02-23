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

    it 'updates existing rounds' do
      round = build(:round, name: 'Gameweek 1', finished: false, external_id: 1)
      round.save

      expect { described_class.call }
        .to change { round.reload.finished }.from(false).to(true)
    end
  end
end
