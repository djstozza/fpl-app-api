require 'rails_helper'

RSpec.describe DraftPicksChannel, type: :channel do
  let(:league) { create :league }

  it 'successfully subscribes' do
    subscribe league_id: league.id
    expect(subscription).to be_confirmed
  end

  it 'rejects a subscription if the league_id is not present' do
    subscribe league_id: nil

    expect(subscription).to be_rejected
  end

  it 'rejects a subscription if the league_id is invalid' do
    subscribe league_id: 'invalid'

    expect(subscription).to be_rejected
  end
end
