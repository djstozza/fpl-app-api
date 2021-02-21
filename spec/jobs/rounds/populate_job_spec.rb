require 'rails_helper'

RSpec.describe Rounds::PopulateJob do
  it 'triggers the populate service' do
    expect(Rounds::Populate).to receive(:call)

    described_class.perform_now
  end
end
