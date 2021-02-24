require 'rails_helper'

RSpec.describe Fixtures::PopulateJob do
  it 'triggers the populate service' do
    expect(Fixtures::Populate).to receive(:call)

    described_class.perform_now
  end
end
