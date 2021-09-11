require 'rails_helper'

RSpec.describe FplTeamListScoreChannel, type: :channel do
  let(:fpl_team_list) { create :fpl_team_list }

  it 'successfully subscribes' do
    subscribe fpl_team_list_id: fpl_team_list.id
    expect(subscription).to be_confirmed
  end

  it 'rejects a subscription if the fpl_team_list_id is not present' do
    subscribe fpl_team_list_id: nil

    expect(subscription).to be_rejected
  end

  it 'rejects a subscription if the fpl_team_list_id is invalid' do
    subscribe fpl_team_list_id: 'invalid'

    expect(subscription).to be_rejected
  end
end
