require 'rails_helper'

RSpec.describe Leagues::Create, type: :service do
  subject(:service) { described_class.call(data, user) }

  let(:user) { create :user }

  let(:data) do
    {
      name: 'New league',
      code: '12345678',
      fpl_team_name: 'New fpl_team',
    }
  end

  it 'creates the league and fpl_team with the user as the owner' do
    expect { service }
      .to change(League, :count).from(0).to(1)
      .and change(FplTeam, :count).from(0).to(1)

    expect(service.league).to be_persisted
    expect(service.league).to have_attributes(
      'name' => 'New league',
      'code' => '12345678',
      'owner' => user,
    )

    expect(service.fpl_team).to be_persisted
    expect(service.fpl_team).to have_attributes(
      'name' => 'New fpl_team',
      'owner' => user,
      'league' => service.league,
    )
  end

  it 'fails if all params are invalid' do
    league = create :league

    data[:name] = league.name
    data[:code] = nil
    data[:fpl_team_name] = nil

    expect { service }
      .to not_change { League.count }
      .and not_change { FplTeam.count }

    expect(service.errors.full_messages).to include(
      'Name has already been taken',
      "Code can't be blank",
      "Fpl team name can't be blank",
    )
  end

  it 'fails if the fpl_team params are invalid' do
    data[:fpl_team_name] = nil

    expect { service }
      .to not_change { League.count }
      .and not_change { FplTeam.count }

    expect(service.errors.full_messages).to include(
      "Fpl team name can't be blank",
    )
  end

  it 'fails if the league params are invalid' do
    data[:name] = nil

    expect { service }
      .to not_change { League.count }
      .and not_change { FplTeam.count }

    expect(service.errors.full_messages).to contain_exactly(
      "Name can't be blank",
    )
  end
end
