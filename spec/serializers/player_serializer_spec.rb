require 'rails_helper'

RSpec.describe PlayerSerializer, type: :serializer do
  let!(:player)  { create :player }
  describe '.has_history' do
    it 'returns true if the history attribute count is > 0' do
      player.update(history: [double('history')])

      expect(described_class.new(player, history: true).as_json).to include(has_history: true)
    end

    it 'returns true if the history attribute count is 0' do
      expect(described_class.new(player, history: true).as_json).to include(has_history: false)
    end
  end

  describe '.has_history_past' do
    it 'returns true if the history attribute count is > 0' do
      player.update(history_past: [double('history_past')])

      expect(described_class.new(player, history_past: true).as_json).to include(has_history_past: true)
    end

    it 'returns true if the history attribute count is 0' do
      expect(described_class.new(player, history_past: true).as_json).to include(has_history_past: false)
    end
  end
end
