require 'rails_helper'

RSpec.describe Positions::PopulateJob do
  it 'triggers the populate service' do
    expect(Positions::Populate).to receive(:call)

    described_class.perform_now
  end
end
