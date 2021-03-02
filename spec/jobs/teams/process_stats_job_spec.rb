require 'rails_helper'

RSpec.describe Teams::ProcessStatsJob do
  it 'triggers the populate service' do
    expect(Teams::ProcessStats).to receive(:call)

    described_class.perform_now
  end
end
