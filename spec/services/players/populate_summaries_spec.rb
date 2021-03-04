require 'rails_helper'

RSpec.describe Players::PopulateSummaries, type: :service do
  describe 'call' do
    it 'triggers Players::PopulateSummary' do
      create :player
      create :player

      expect(Players::PopulateSummary).to receive(:call).twice

      described_class.call
    end
  end
end
