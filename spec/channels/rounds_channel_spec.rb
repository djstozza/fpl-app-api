require 'rails_helper'

RSpec.describe RoundsChannel, type: :channel do
  let(:round) { create :round }

  it 'successfully subscribes' do
    subscribe round_id: round.id
    expect(subscription).to be_confirmed
  end

  it 'rejects a subscription if the round_id is not present' do
    subscribe round_id: nil

    expect(subscription).to be_rejected
  end

  it 'rejects a subscription if the round_id is invalid' do
    subscribe round_id: 'invalid'

    expect(subscription).to be_rejected
  end
end
