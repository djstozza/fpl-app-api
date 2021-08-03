require 'rails_helper'

RSpec.describe Leagues::UpdateDraftPick, type: :service do
  subject(:service) { described_class.call(data, league, draft_pick, user) }

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

  describe 'drafting a player' do
    let(:data) { { player_id: player.id } }

    it 'adds the player to the daft pick and updates the next draft pick of the league' do
      next_draft_pick.save!

      expect { service }
        .to change { draft_pick.reload.player }.from(nil).to(player)
        .and change(league, :current_draft_pick).from(draft_pick).to(next_draft_pick)
        .and change { fpl_team.players.count }.from(0).to(1)
        .and change { league.players.count }.from(0).to(1)
        .and enqueue_job(DraftPicks::BroadcastJob).with(draft_pick.id)
    end

    it 'fails if the player_id is invalid' do
      data[:player_id] = 'invalid'

      expect { service }
        .to not_change { draft_pick.reload.updated_at }
        .and not_change { fpl_team.players.count }
        .and not_change { league.players.count }
        .and enqueue_job(DraftPicks::BroadcastJob).exactly(0).times

      expect(service.errors.full_messages).to contain_exactly('Player is invalid')
    end

    it 'fails if a player_id is present and mini_draft = true' do
      data[:mini_draft] = true

      expect { service }
        .to not_change { draft_pick.reload.updated_at }
        .and not_change { fpl_team.players.count }
        .and not_change { league.players.count }
        .and not_change { fpl_team.reload.updated_at }
        .and enqueue_job(DraftPicks::BroadcastJob).exactly(0).times

      expect(service.errors.full_messages)
        .to contain_exactly('Either select a player or a mini draft pick number')
    end

    it 'fails if player_id is blank and mini_draft = false' do
      data[:player_id] = nil
      data[:mini_draft] = false

      expect { service }
        .to not_change { draft_pick.reload.updated_at }
        .and not_change { fpl_team.players.count }
        .and not_change { league.players.count }
        .and not_change { fpl_team.reload.updated_at }
        .and enqueue_job(DraftPicks::BroadcastJob).exactly(0).times

      expect(service.errors.full_messages)
        .to contain_exactly('Either select a player or a mini draft pick number')
    end

    it 'does not draft the player if the league status is incorrect' do
      league.update(status: 'initialized')

      expect { service }
        .to not_change { draft_pick.reload.updated_at }
        .and not_change { fpl_team.players.count }
        .and not_change { league.players.count }
        .and enqueue_job(DraftPicks::BroadcastJob).exactly(0).times

      expect(service.errors.full_messages)
        .to contain_exactly('You cannot draft players at this time')

      expect(league.current_draft_pick).to eq(draft_pick)
    end

    it 'does not draft the player if the user is not authorised' do
      draft_pick.fpl_team.update(owner: create(:user))

      expect { service }
        .to not_change { draft_pick.reload.updated_at }
        .and not_change { fpl_team.players.count }
        .and not_change { league.players.count }
        .and enqueue_job(DraftPicks::BroadcastJob).exactly(0).times

      expect(service.errors.full_messages)
        .to contain_exactly('You are not authorised to perform this action')

      expect(league.current_draft_pick).to eq(draft_pick)
    end

    it 'does not draft the player if the draft pick is not current' do
      next_draft_pick.save!
      service = described_class.call({ player_id: player.id }, league, next_draft_pick, user)

      expect { service }
        .to not_change { draft_pick.reload.updated_at }
        .and enqueue_job(DraftPicks::BroadcastJob).exactly(0).times

      expect(service.errors.full_messages)
        .to contain_exactly('You cannot pick out of turn')

      expect(league.current_draft_pick).to eq(draft_pick)
    end

    it 'fails if the quota of forwards is exceeded' do
      FplTeam::QUOTAS[:forwards].times do
        fpl_team.players << create(:player, :forward)
      end

      expect { service }
        .to not_change { draft_pick.reload.updated_at }
        .and not_change { fpl_team.players.count }
        .and not_change { league.players.count }
        .and enqueue_job(DraftPicks::BroadcastJob).exactly(0).times

      expect(service.errors.full_messages)
        .to contain_exactly("You cannot have more than #{FplTeam::QUOTAS[:forwards]} forwards in your team")
    end

    it 'fails if the quota of defenders is exceeded' do
      position = create(:position, :defender)
      player.update(position: position)

      FplTeam::QUOTAS[:defenders].times do
        fpl_team.players << create(:player, :defender)
      end

      expect { service }
        .to not_change { draft_pick.reload.updated_at }
        .and not_change { fpl_team.players.count }
        .and not_change { league.players.count }
        .and enqueue_job(DraftPicks::BroadcastJob).exactly(0).times

      expect(service.errors.full_messages)
        .to contain_exactly("You cannot have more than #{FplTeam::QUOTAS[:defenders]} defenders in your team")
    end

    it 'fails if the quota of midfielders is exceeded' do
      position = create(:position, :midfielder)
      player.update(position: position)

      FplTeam::QUOTAS[:midfielders].times do
        fpl_team.players << create(:player, position: position)
      end

      expect { service }
        .to not_change { draft_pick.reload.updated_at }
        .and not_change { fpl_team.players.count }
        .and not_change { league.players.count }
        .and enqueue_job(DraftPicks::BroadcastJob).exactly(0).times

      expect(service.errors.full_messages)
        .to contain_exactly("You cannot have more than #{FplTeam::QUOTAS[:midfielders]} midfielders in your team")
    end

    it 'fails if the quota of goalkeepers is exceeded' do
      position = create(:position, :goalkeeper)
      player.update(position: position)

      FplTeam::QUOTAS[:goalkeepers].times do
        fpl_team.players << create(:player, :goalkeeper)
      end

      expect { service }
        .to not_change { draft_pick.reload.updated_at }
        .and not_change { fpl_team.players.count }
        .and not_change { league.players.count }
        .and enqueue_job(DraftPicks::BroadcastJob).exactly(0).times

      expect(service.errors.full_messages)
        .to contain_exactly("You cannot have more than #{FplTeam::QUOTAS[:goalkeepers]} goalkeepers in your team")
    end

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

      expect { service }
        .to not_change { draft_pick.reload.updated_at }
        .and not_change { fpl_team.players.count }
        .and not_change { league.players.count }
        .and enqueue_job(DraftPicks::BroadcastJob).exactly(0).times

      expect(service.errors.full_messages)
        .to include("You are only allowed #{FplTeam::QUOTAS[:players]} players in a team")
    end

    it 'fails if the fpl_team already has the quota of players from the same team' do
      FplTeam::QUOTAS[:team].times do
        fpl_team.players << create(:player, :midfielder, team: player.team)
      end

      expect { service }
        .to not_change { draft_pick.reload.updated_at }
        .and not_change { fpl_team.players.count }
        .and not_change { league.players.count }
        .and enqueue_job(DraftPicks::BroadcastJob).exactly(0).times

      expect(service.errors.full_messages).to contain_exactly(
        "You cannot have more than #{FplTeam::QUOTAS[:team]} players from the same team (#{player.team.name})"
      )
    end

    it 'fails if the player has already picked' do
      other_fpl_team = create(:fpl_team, league: league)
      other_fpl_team.players << player

      expect { service }
        .to not_change { draft_pick.reload.updated_at }
        .and not_change { fpl_team.players.count }
        .and not_change { league.players.count }
        .and enqueue_job(DraftPicks::BroadcastJob).exactly(0).times

      expect(service.errors.full_messages)
        .to contain_exactly("#{player.name} has already been picked")
    end
  end

  describe 'making a mini draft pick' do
    let(:data) { { mini_draft: true } }

    it 'sets mini_draft to true and updates the next draft pick of the league' do
      next_draft_pick.save!
      data[:player_id] = nil
      data[:mini_draft] = true

      expect { service }
        .to change { draft_pick.reload.mini_draft }.from(false).to(true)
        .and change(league, :current_draft_pick).from(draft_pick).to(next_draft_pick)
        .and change { fpl_team.reload.mini_draft_pick_number }.from(nil).to(1)
        .and enqueue_job(DraftPicks::BroadcastJob).with(draft_pick.id)
    end

    it 'does not set the mini_draft pick if the league status is incorrect' do
      league.update(status: 'initialized')

      expect { service }
        .to not_change { draft_pick.reload.updated_at }
        .and not_change { fpl_team.reload.updated_at }
        .and enqueue_job(DraftPicks::BroadcastJob).exactly(0).times

      expect(service.errors.full_messages)
        .to contain_exactly('You cannot draft players at this time')

      expect(league.current_draft_pick).to eq(draft_pick)
    end

    it 'does not set the mini_draft pick if the user is not authorised' do
      draft_pick.fpl_team.update(owner: create(:user))

      expect { service }
        .to not_change { draft_pick.reload.updated_at }
        .and not_change { fpl_team.reload.updated_at }
        .and enqueue_job(DraftPicks::BroadcastJob).exactly(0).times

      expect(service.errors.full_messages)
        .to contain_exactly('You are not authorised to perform this action')

      expect(league.current_draft_pick).to eq(draft_pick)
    end

    it 'does not set the mini_draft pick if the draft pick is not current' do
      next_draft_pick.save!
      service = described_class.call({ mini_draft: true }, league, next_draft_pick, user)

      expect { service }
        .to not_change { draft_pick.reload.updated_at }
        .and not_change { fpl_team.reload.updated_at }
        .and enqueue_job(DraftPicks::BroadcastJob).exactly(0).times

      expect(service.errors.full_messages)
        .to contain_exactly('You cannot pick out of turn')

      expect(league.current_draft_pick).to eq(draft_pick)
    end

    it 'fails if the mini draft has already been picked' do
      create(:draft_pick, :mini_draft, fpl_team: fpl_team)

      expect { service }
        .to not_change { draft_pick.reload.updated_at }
        .and not_change { fpl_team.reload.updated_at }
        .and enqueue_job(DraftPicks::BroadcastJob).exactly(0).times

      expect(service.errors.full_messages)
        .to contain_exactly('You have already selected your position in the mini draft')
    end
  end
end
