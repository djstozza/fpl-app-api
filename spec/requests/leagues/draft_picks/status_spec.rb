require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to test the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator. If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails. There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.

RSpec.describe 'api/leagues/league_id/draft_picks/status', :no_transaction, type: :request do
  let!(:user) { create :user }
  let!(:league) { create :league, status: 'draft' }
  let!(:fpl_team) { create :fpl_team, league: league, owner: user }
  let!(:draft_pick1) { create :draft_pick, league: league, fpl_team: fpl_team }
  let!(:draft_pick2) { create :draft_pick, :mini_draft, league: league, fpl_team: create(:fpl_team, league: league) }
  let!(:draft_pick3) { create :draft_pick, :initialized, league: league, fpl_team: create(:fpl_team, league: league) }
  let(:player) { create :player, :forward }

  describe 'GET /index' do
    it 'renders a list of of draft_picks and whether the user can pick' do
      api.authenticate(user)

      api.get api_league_draft_picks_status_index_path(league)

      expect(api.data['draft_finished']).to eq(false)
      expect(api.data['user_can_pick']).to eq(false)
      expect(api.data['next_draft_pick_id']).to eq(draft_pick3.to_param)
      expect(api.data['can_make_player_pick']).to eq(true)
      expect(api.data['can_make_mini_draft_pick']).to eq(true)
    end

    it 'returns user_can_pick = true if the draft pick owner is next' do
      api.authenticate(draft_pick3.owner)

      api.get api_league_draft_picks_status_index_path(league)

      expect(api.data['draft_finished']).to eq(false)
      expect(api.data['user_can_pick']).to eq(true)
      expect(api.data['next_draft_pick_id']).to eq(draft_pick3.to_param)
      expect(api.data['can_make_player_pick']).to eq(true)
      expect(api.data['can_make_mini_draft_pick']).to eq(true)
    end

    it 'returns draft_finished = true when all the picks have a mini_draft pick or a player associated with them' do
      draft_pick3.update(mini_draft: true)
      api.authenticate(user)

      api.get api_league_draft_picks_status_index_path(league)

      expect(api.data['draft_finished']).to eq(true)
      expect(api.data['user_can_pick']).to eq(false)
      expect(api.data['next_draft_pick_id']).to eq(nil)
    end

    it 'returns draft_finished = false if the can_go_to_draft? is false' do
      league.update(status: 'initialized')
      draft_pick3.update(mini_draft: true)
      api.authenticate(user)

      api.get api_league_draft_picks_status_index_path(league)

      expect(api.data['draft_finished']).to eq(false)
      expect(api.data['user_can_pick']).to eq(false)
      expect(api.data['next_draft_pick_id']).to eq(nil)
    end

    it 'returns can_make_player_pick = false if the players quota has been reached' do
      (FplTeam::QUOTAS[:players] - 1).times do
        create(:draft_pick, league: league, fpl_team: fpl_team)
      end

      api.authenticate(user)

      api.get api_league_draft_picks_status_index_path(league)

      expect(api.data['can_make_player_pick']).to eq(false)
    end

    it 'returns can_make_mini_draft_pick = false if the user has made a mini draft pick' do
      api.authenticate(draft_pick2.owner)

      api.get api_league_draft_picks_status_index_path(league)

      expect(api.data['can_make_mini_draft_pick']).to eq(false)
    end
  end
end
