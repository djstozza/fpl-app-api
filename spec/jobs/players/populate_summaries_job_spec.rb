require 'rails_helper'

RSpec.describe Players::PopulateSummariesJob do
  it 'triggers the populate service' do
    expect(Players::PopulateSummaries).to receive(:call)

    described_class.perform_now
  end
end
