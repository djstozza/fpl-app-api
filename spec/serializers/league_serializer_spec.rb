# == Schema Information
#
# Table name: leagues
#
#  id              :bigint           not null, primary key
#  active          :boolean          default(TRUE), not null
#  code            :string           not null
#  fpl_teams_count :integer          default(0), not null
#  name            :citext           not null
#  status          :integer          default("initialized"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  owner_id        :bigint
#
# Indexes
#
#  index_leagues_on_name      (name) UNIQUE
#  index_leagues_on_owner_id  (owner_id)
#
require 'rails_helper'

RSpec.describe LeagueSerializer, type: :serializer do
  subject(:serializer_with_owner) { described_class.new(league, current_user: league.owner).as_json }

  let!(:round) { create :round, :current }
  let(:serializer) { described_class.new(league).as_json }
  let(:league) { create :league }
  let(:user) { create :user }

  let(:serializer_without_owner) { described_class.new(league, current_user: user).as_json }

  describe '#show_draft_pick_column' do
    it 'is false if the league is initialized' do
      expect(serializer).to include(show_draft_pick_column: false)
    end

    it 'is true if the league status is draft_picks_generated' do
      league.update!(status: 'draft_picks_generated')
      expect(serializer).to include(show_draft_pick_column: true)
    end

    it 'is true if the league status is draft' do
      league.update(status: 'draft')
      expect(serializer).to include(show_draft_pick_column: true)
    end

    it 'is true if the league status is live' do
      league.update(status: 'live')
      expect(serializer).to include(show_live_columns: true)
    end
  end

  describe '#show_live_columns' do
    it 'is false if the league is initialized' do
      expect(serializer).to include(show_live_columns: false)
    end

    it 'is false if the league status is draft_picks_generated' do
      league.update!(status: 'draft_picks_generated')
      expect(serializer).to include(show_live_columns: false)
    end

    it 'is false if the league status is draft' do
      league.update(status: 'draft')
      expect(serializer).to include(show_live_columns: false)
    end

    it 'is true if the league status is live' do
      league.update(status: 'live')
      expect(serializer).to include(show_live_columns: true)
    end
  end

  describe '#code' do
    it 'is visible if the league owner is the current_user' do
      expect(serializer).not_to include(:code)
      expect(serializer_without_owner).not_to include(:code)
      expect(serializer_with_owner).to include(code: league.code)
    end
  end

  describe '#can_generate_draft_picks' do
    it 'is true if can_generate_draft_picks? is satisfied and the current_user is the owner' do
      League::MIN_FPL_TEAM_QUOTA.times do
        create(:fpl_team, league: league)
      end

      expect(serializer).not_to include(:can_generate_draft_picks)
      expect(serializer_without_owner).not_to include(:can_generate_draft_picks)
      expect(serializer_with_owner).to include(can_generate_draft_picks: true)
    end
  end

  describe '#can_generate_draft' do
    it 'is false if the league is initialized' do
      expect(serializer_with_owner).to include(can_create_draft: false)
    end

    it 'is true if the league status is draft_picks_generated and the the current_user is the owner' do
      league.update(status: 'draft_picks_generated')

      expect(serializer).not_to include(:can_create_draft)
      expect(serializer_without_owner).not_to include(:can_create_draft)
      expect(serializer_with_owner).to include(can_create_draft: true)
    end

    it 'is false if the league status is draft' do
      league.update(status: 'draft')
      expect(serializer_with_owner).to include(can_create_draft: false)
    end

    it 'is false if the league status is live' do
      league.update(status: 'live')
      expect(serializer_with_owner).to include(can_create_draft: false)
    end
  end

  describe '#can_go_to_draft' do
    it 'is false if the league is initialized' do
      expect(serializer).to include(can_go_to_draft: false)
    end

    it 'is false if the status is draft_picks_generated' do
      league.update(status: 'draft_picks_generated')
      expect(serializer).to include(can_go_to_draft: false)
    end

    it 'is true if the league status is draft' do
      league.update(status: 'draft')
      expect(serializer).to include(can_go_to_draft: true)
    end

    it 'is true if the league status is live' do
      league.update(status: 'live')
      expect(serializer).to include(can_go_to_draft: true)
    end
  end

  describe '#can_go_to_mini_draft' do
    it 'is false if the league is not live' do
      round.update(mini_draft: true)
      expect(serializer).to include(can_go_to_mini_draft: false)
    end

    it 'is false if the round is not a mini draft round' do
      league.update(status: 'live')
      expect(serializer).to include(can_go_to_mini_draft: false)
    end

    it 'is true if the round is a mini draft round and the league is live' do
      league.update(status: 'live')
      round.update(mini_draft: true)
      expect(serializer).to include(can_go_to_mini_draft: true)
    end
  end
end
