require 'rails_helper'

RSpec.describe Players::PopulateJob do
  it 'triggers the populate service' do
    expect(Players::Populate).to receive(:call)

    described_class.perform_now
  end
end
