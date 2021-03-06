require 'rails_helper'

RSpec.describe Fixtures::PopulateJob do
  it 'triggers the populate service' do
    round = build :round, :current
    round.save

    expect(Fixtures::Populate).to receive(:call).with(round)

    described_class.perform_now
  end

  it 'does not trigger the populate service if there is no current round' do
    expect(Fixtures::Populate).not_to receive(:call)

    described_class.perform_now
  end
end
