require 'rails_helper'

RSpec.describe Leagues::Join, type: :service do
  subject(:service) { described_class.call(data, user, league: league) }

  let(:user) { create :user }
  let!(:league) { create :league }
  let(:data) do
    {
      code: league.code,
      fpl_team_name: 'New fpl_team',
    }
  end

  it 'creates fpl_team with the user as the owner' do
    expect { service }
      .to not_change { League.count }
      .and change(FplTeam, :count).from(0).to(1)

    expect(service.fpl_team).to have_attributes(
      'name' => 'New fpl_team',
      'owner' => user,
      'league' => service.league,
    )
  end

  it 'fails if the code is incorrect' do
    data[:code] = 'incorrect'

    expect { service }.not_to change(FplTeam, :count)

    expect(service.errors.full_messages).to contain_exactly(
      'Code is incorrect'
    )
  end

  it 'fails if the fpl_team name is invalid' do
    fpl_team = create :fpl_team

    data[:fpl_team_name] = fpl_team.name

    expect { service }.not_to change(FplTeam, :count)

    expect(service.errors.full_messages).to include(
      'Fpl team name has already been taken',
    )
  end

  it 'fails if the user has already joined' do
    create(:fpl_team, league: league, owner: user)

    expect { service }.not_to change(FplTeam, :count)

    expect(service.errors.full_messages).to contain_exactly(
      'You have already joined this league'
    )
  end

  it 'fails if the max quota of fpl_teams has been reached' do
    stub_const('League::MAX_FPL_TEAM_QUOTA', 0)

    expect { service }.not_to change(FplTeam, :count)

    expect(service.errors.full_messages).to contain_exactly(
      'This league has no more spaces left'
    )
  end

  it 'fails if the league does not exist' do
    service = described_class.call(data, user, league: nil)

    expect { service }.not_to change(FplTeam, :count)

    expect(service.errors.full_messages).to contain_exactly(
      'Name does not match with any league on record'
    )
  end
end
