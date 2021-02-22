require 'rails_helper'

RSpec.describe Teams::PopulateJob do
  it 'triggers the populate service' do
    expect(Teams::Populate).to receive(:call)

    described_class.perform_now
  end
end
