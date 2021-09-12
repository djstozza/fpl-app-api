require 'rails_helper'

RSpec.describe Rounds::ProcessCurrentRoundFixturesJob do
  let!(:round) { create :round, :current }

  it 'triggers the populate service' do
    expect(Fixtures::Populate).to receive(:call).with(round)

    expect { described_class.perform_now }.to have_broadcasted_to("round_#{round.id}").with do |data|
      expect(data['updatedAt']).to be_within(1).of(Time.current.to_i)
    end
  end

  it 'does not trigger the populate service if there is no current round' do
    round.update(is_current: false)
    expect(Fixtures::Populate).not_to receive(:call)

    expect { described_class.perform_now }.not_to have_broadcasted_to("round_#{round.id}")
  end
end
