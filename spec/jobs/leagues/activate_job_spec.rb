require 'rails_helper'

RSpec.describe Leagues::ActivateJob do
  let!(:league) { create :league, status: 'draft' }
  it 'triggers the activate service' do
    expect(Leagues::Activate).to receive(:call).with(league).and_return(double(errors: []))

    described_class.perform_now(league.id)
  end
end
