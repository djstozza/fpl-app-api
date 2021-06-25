require 'rails_helper'

RSpec.describe FplTeams::Update, type: :service do
  subject(:service) { described_class.call(data, fpl_team, user) }
  let(:user) { create :user }
  let!(:fpl_team) { create :fpl_team, owner: user }

  let(:data) { { name: 'New Name' } }

  it 'updates the league if the user is the owner' do
    expect { service }
      .to change { fpl_team.reload.name }.to('New Name')
  end

  it 'fails if the params are invalid' do
    another_fpl_team = create :fpl_team

    data[:name] = another_fpl_team.name

    expect { service }.not_to change { fpl_team.reload.updated_at }
    expect(service.errors.full_messages).to include(
      'Name has already been taken',
    )
  end

  it 'fails if the user is not the owner' do
    fpl_team.update(owner: create(:user))

    expect { service }.not_to change { fpl_team.reload.updated_at }

    expect(service.errors.full_messages).to contain_exactly(
      'You are not authorised to perform this action',
    )
  end
end
