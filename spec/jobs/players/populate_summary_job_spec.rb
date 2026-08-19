require 'rails_helper'

RSpec.describe Players::PopulateSummaryJob do
  it 'calls Players::PopulateSummary for the player' do
    player = create :player

    expect(Players::PopulateSummary).to receive(:call).with(player)

    described_class.new.perform(player.id)
  end
end
