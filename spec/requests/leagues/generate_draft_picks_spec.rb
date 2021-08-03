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

RSpec.describe 'api/leagues/league_id/generate_drafts', type: :request do
  let!(:user) { create :user }
  let!(:league) { create :league, owner: user }

  before do
    League::MIN_FPL_TEAM_QUOTA.times do
      create(:fpl_team, league: league)
    end
  end

  describe 'POST /create' do
    it 'generates fpl_team draft pick numbers and transitions the league to draft_picks_generated' do
      api.authenticate(user)

      expect { api.post api_league_generate_draft_picks_path(league.id) }
        .to change { league.reload.status }.from('initialized').to('draft_picks_generated')

      expect(league.fpl_teams.pluck(:draft_pick_number)).to all(be_an(Integer))
    end

    it 'responds with a 422 message if params invalid' do
      another_user = create :user
      api.authenticate(another_user)

      expect { api.post api_league_generate_draft_picks_path(league.id) }.not_to change { league.reload.status }

      expect(api.response).to have_http_status(:unprocessable_entity)

      expect(api.errors).to contain_exactly(
        a_hash_including('detail' => 'You are not authorised to perform this action', 'source' => 'base'),
      )
    end
  end
end
