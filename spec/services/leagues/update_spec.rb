require 'rails_helper'

RSpec.describe Leagues::Update, type: :service do
  subject(:service) { described_class.call(data, user, league: league) }

  let(:user) { create :user }
  let!(:league) { create :league, owner: user }

  let(:data) do
    {
      name: 'New Name',
      code: '87654321',
    }
  end

  it 'updates the league if the user is the owner' do
    expect { service }
      .to change { league.reload.name }.to('New Name')
      .and change { league.reload.code }.to('87654321')
  end

  it 'fails if all params are invalid' do
    another_league = create :league

    data[:name] = another_league.name
    data[:code] = nil

    expect { service }.not_to change { league.reload.updated_at }
    expect(service.errors.full_messages).to contain_exactly(
      'Name has already been taken',
      "Code can't be blank",
    )
  end

  it 'fails if the user is not the owner' do
    league.update(owner: create(:user))

    expect { service }.not_to change { league.reload.updated_at }

    expect(service.errors.full_messages).to contain_exactly(
      'You are not authorised to perform this action',
    )
  end
end
