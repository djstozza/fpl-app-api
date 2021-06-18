require 'rails_helper'

RSpec.describe Leagues::UpdateDraftPick, type: :service do
  subject(:player_draft_service) { described_class.call({ player_id: player.id }, league, draft_pick, user) }
  subject(:mini_draft_service) { described_class.call({ mini_draft: true }, league, draft_pick, user) }
  let(:player) { create :player, :forward }
  let(:league) { create :league, status: 'draft' }
  let(:user) { create :user }
  let(:fpl_team) { create :fpl_team, league: league, owner: user }
  let(:draft_pick) { create :draft_pick, :initialized, league: league, fpl_team: fpl_team }
  let(:next_fpl_team) { create :fpl_team, league: league }
  let(:next_draft_pick) do
    build(
      :draft_pick,
      :initialized,
      fpl_team: fpl_team,
      pick_number: draft_pick.pick_number + 1,
    )
  end

  it 'adds the player to the daft pick and updates the next draft pick of the league' do
    next_draft_pick.save!

    expect { player_draft_service }
      .to change { draft_pick.reload.player }.from(nil).to(player)
      .and change { league.current_draft_pick }.from(draft_pick).to(next_draft_pick)
      .and change { fpl_team.players.count }.from(0).to(1)
      .and change { league.players.count }.from(0).to(1)
      .and have_broadcasted_to("league_#{league.id}_draft_picks").with(
        updatedAt: draft_pick.reload.updated_at.to_i,
        message: "#{user.username} has drafted #{player.first_name} #{player.last_name} (#{player.team.short_name})"
      )
  end

  it 'sets mini_draft to true and updates the next draft pick of the league' do
    next_draft_pick.save!

    expect { mini_draft_service }
      .to change { draft_pick.reload.mini_draft }.from(false).to(true)
      .and change { league.current_draft_pick }.from(draft_pick).to(next_draft_pick)
      .and change { fpl_team.reload.mini_draft_pick_number }.from(nil).to(1)
      .and have_broadcasted_to("league_#{league.id}_draft_picks").with(
        updatedAt: draft_pick.reload.updated_at.to_i,
        message: "#{user.username} has made a mini draft pick"
      )
  end

  it 'fails if the player_id is invalid' do
    service = described_class.call({ player_id: 'invalid', mini_draft: false }, league, draft_pick, user)

    expect { service }
      .to change { draft_pick.reload.updated_at }.by(0)
      .and change { fpl_team.players.count }.by(0)
      .and change { league.players.count }.by(0)
      .and have_broadcasted_to("league_#{league.id}_draft_picks").exactly(0).times

    expect(service.errors.full_messages).to contain_exactly('Player is invalid')
  end

  describe '#valid_data' do
    it 'fails if a player_id is present and mini_draft = true' do
      service = described_class.call({ player_id: player.id, mini_draft: true }, league, draft_pick, user)

      expect { service }
        .to change { draft_pick.reload.updated_at }.by(0)
        .and change { fpl_team.players.count }.by(0)
        .and change { league.players.count }.by(0)
        .and change { fpl_team.reload.updated_at }.by(0)
        .and have_broadcasted_to("league_#{league.id}_draft_picks").exactly(0).times

      expect(service.errors.full_messages)
        .to contain_exactly('Either select a player or a mini draft pick number')
    end

    it 'fails if player_id is blank and mini_draft = false' do
      service = described_class.call({ player_id: nil, mini_draft: false }, league, draft_pick, user)

      expect { service }
        .to change { draft_pick.reload.updated_at }.by(0)
        .and change { fpl_team.players.count }.by(0)
        .and change { league.players.count }.by(0)
        .and change { fpl_team.reload.updated_at }.by(0)
        .and have_broadcasted_to("league_#{league.id}_draft_picks").exactly(0).times

      expect(service.errors.full_messages)
        .to contain_exactly('Either select a player or a mini draft pick number')
    end
  end

  describe '#league_status' do
    before do
      league.update(status: 'initialized')
    end

    it 'does not draft the player if invalid' do
      expect { player_draft_service }
        .to change { draft_pick.reload.updated_at }.by(0)
        .and change { fpl_team.players.count }.by(0)
        .and change { league.players.count }.by(0)
        .and have_broadcasted_to("league_#{league.id}_draft_picks").exactly(0).times

      expect(player_draft_service.errors.full_messages)
        .to contain_exactly('You cannot draft players at this time')

      expect(league.current_draft_pick).to eq(draft_pick)
    end

    it 'does not set the mini_draft pick if invalid' do
      expect { mini_draft_service }
        .to change { draft_pick.reload.updated_at }.by(0)
        .and change { fpl_team.reload.updated_at }.by(0)
        .and have_broadcasted_to("league_#{league.id}_draft_picks").exactly(0).times

      expect(mini_draft_service.errors.full_messages)
        .to contain_exactly('You cannot draft players at this time')

      expect(league.current_draft_pick).to eq(draft_pick)
    end
  end

  describe '#user_is_fpl_team_owner' do
    let(:draft_pick) { create :draft_pick, :initialized, fpl_team: create(:fpl_team, league: league) }

    it 'does not draft the player if invalid' do
      expect { player_draft_service }
        .to change { draft_pick.reload.updated_at }.by(0)
        .and change { fpl_team.players.count }.by(0)
        .and change { league.players.count }.by(0)
        .and have_broadcasted_to("league_#{league.id}_draft_picks").exactly(0).times

      expect(player_draft_service.errors.full_messages)
        .to contain_exactly('You are not authorised to perform this action')

      expect(league.current_draft_pick).to eq(draft_pick)
    end

    it 'does not set the mini_draft pick if invalid' do
      expect { mini_draft_service }
        .to change { draft_pick.reload.updated_at }.by(0)
        .and change { fpl_team.reload.updated_at }.by(0)
        .and have_broadcasted_to("league_#{league.id}_draft_picks").exactly(0).times

      expect(mini_draft_service.errors.full_messages)
        .to contain_exactly('You are not authorised to perform this action')

      expect(league.current_draft_pick).to eq(draft_pick)
    end
  end

  describe '#draft_pick_is_current' do
    it 'does not draft the player if invalid' do
      next_draft_pick.save!
      service = described_class.call({ player_id: player.id }, league, next_draft_pick, user)

      expect { service }
        .to change { draft_pick.reload.updated_at }.by(0)
        .and have_broadcasted_to("league_#{league.id}_draft_picks").exactly(0).times

      expect(service.errors.full_messages)
        .to contain_exactly('You cannot pick out of turn')

      expect(league.current_draft_pick).to eq(draft_pick)
    end

    it 'does not set the mini_draft pick if invalid' do
      next_draft_pick.save!
      service = described_class.call({ mini_draft: true }, league, next_draft_pick, user)

      expect { service }
        .to change { draft_pick.reload.updated_at }.by(0)
        .and change { fpl_team.reload.updated_at }.by(0)
        .and have_broadcasted_to("league_#{league.id}_draft_picks").exactly(0).times

      expect(service.errors.full_messages)
        .to contain_exactly('You cannot pick out of turn')

      expect(league.current_draft_pick).to eq(draft_pick)
    end
  end

  describe '#valid_position' do
    it 'fails if the quota of forwards is exceeded' do
      FplTeam::QUOTAS[:forwards].times do
        fpl_team.players << create(:player, :forward)
      end

      expect { player_draft_service }
        .to change { draft_pick.reload.updated_at }.by(0)
        .and change { fpl_team.players.count }.by(0)
        .and change { league.players.count }.by(0)
        .and have_broadcasted_to("league_#{league.id}_draft_picks").exactly(0).times

      expect(player_draft_service.errors.full_messages)
        .to contain_exactly("You cannot have more than #{FplTeam::QUOTAS[:forwards]} forwards in your team")
    end

    it 'fails if the quota of defenders is exceeded' do
      position = create(:position, :defender)
      player.update(position: position)

      FplTeam::QUOTAS[:defenders].times do
        fpl_team.players << create(:player, :defender)
      end

      expect { player_draft_service }
        .to change { draft_pick.reload.updated_at }.by(0)
        .and change { fpl_team.players.count }.by(0)
        .and change { league.players.count }.by(0)
        .and have_broadcasted_to("league_#{league.id}_draft_picks").exactly(0).times

      expect(player_draft_service.errors.full_messages)
        .to contain_exactly("You cannot have more than #{FplTeam::QUOTAS[:defenders]} defenders in your team")
    end

    it 'fails if the quota of midfielders is exceeded' do
      position = create(:position, :midfielder)
      player.update(position: position)

      FplTeam::QUOTAS[:midfielders].times do
        fpl_team.players << create(:player, :midfielder)
      end

      expect { player_draft_service }
        .to change { draft_pick.reload.updated_at }.by(0)
        .and change { fpl_team.players.count }.by(0)
        .and change { league.players.count }.by(0)
        .and have_broadcasted_to("league_#{league.id}_draft_picks").exactly(0).times

      expect(player_draft_service.errors.full_messages)
        .to contain_exactly("You cannot have more than #{FplTeam::QUOTAS[:midfielders]} midfielders in your team")
    end

    it 'fails if the quota of goalkeepers is exceeded' do
      position = create(:position, :goalkeeper)
      player.update(position: position)

      FplTeam::QUOTAS[:goalkeepers].times do
        fpl_team.players << create(:player, :goalkeeper)
      end

      expect { player_draft_service }
        .to change { draft_pick.reload.updated_at }.by(0)
        .and change { fpl_team.players.count }.by(0)
        .and change { league.players.count }.by(0)
        .and have_broadcasted_to("league_#{league.id}_draft_picks").exactly(0).times

      expect(player_draft_service.errors.full_messages)
        .to contain_exactly("You cannot have more than #{FplTeam::QUOTAS[:goalkeepers]} goalkeepers in your team")
    end
  end

  describe '#valid_player_count' do
    it 'fails if the fpl_team has the full complement of players' do
      FplTeam::QUOTAS[:forwards].times do
        fpl_team.players << create(:player, :forward)
      end

      FplTeam::QUOTAS[:defenders].times do
        fpl_team.players << create(:player, :defender)
      end

      FplTeam::QUOTAS[:midfielders].times do
        fpl_team.players << create(:player, :midfielder)
      end

      FplTeam::QUOTAS[:goalkeepers].times do
        fpl_team.players << create(:player, :goalkeeper)
      end

      expect { player_draft_service }
        .to change { draft_pick.reload.updated_at }.by(0)
        .and change { fpl_team.players.count }.by(0)
        .and change { league.players.count }.by(0)
        .and have_broadcasted_to("league_#{league.id}_draft_picks").exactly(0).times

      expect(player_draft_service.errors.full_messages)
        .to include("You are only allowed #{FplTeam::QUOTAS[:players]} players in a team")
    end
  end

  describe '#maximum_number_of_players_from_team' do
    it 'fails if the fpl_team already has the quota of players from the same team' do
      FplTeam::QUOTAS[:team].times do
        fpl_team.players << create(:player, team: player.team)
      end

      expect { player_draft_service }
        .to change { draft_pick.reload.updated_at }.by(0)
        .and change { fpl_team.players.count }.by(0)
        .and change { league.players.count }.by(0)
        .and have_broadcasted_to("league_#{league.id}_draft_picks").exactly(0).times

      expect(player_draft_service.errors.full_messages).to contain_exactly(
        "You cannot have more than #{FplTeam::QUOTAS[:team]} players from the same team (#{player.team.name})"
      )
    end
  end

  describe '#player_not_already_picked' do
    it 'fails if the player has already picked' do
      other_fpl_team = create(:fpl_team, league: league)
      other_fpl_team.players << player

      expect { player_draft_service }
        .to change { draft_pick.reload.updated_at }.by(0)
        .and change { fpl_team.players.count }.by(0)
        .and change { league.players.count }.by(0)
        .and have_broadcasted_to("league_#{league.id}_draft_picks").exactly(0).times

      expect(player_draft_service.errors.full_messages)
        .to contain_exactly("#{player.first_name} #{player.last_name} has already been picked")
    end
  end

  describe '#valid_mini_draft_pick' do
    it 'fails if the mini draft has already been picked' do
      create(:draft_pick, :mini_draft, fpl_team: fpl_team)

      expect { mini_draft_service }
        .to change { draft_pick.reload.updated_at }.by(0)
        .and change { fpl_team.reload.updated_at }.by(0)
        .and have_broadcasted_to("league_#{league.id}_draft_picks").exactly(0).times

      expect(mini_draft_service.errors.full_messages)
        .to contain_exactly('You have already selected your position in the mini draft')
    end
  end
end
