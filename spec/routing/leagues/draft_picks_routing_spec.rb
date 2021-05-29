require 'rails_helper'

RSpec.describe Api::Leagues::DraftPicksController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: 'api/leagues/1/draft_picks').to route_to('api/leagues/draft_picks#index', league_id: '1')
    end

    it 'does not route to #show' do
      expect(get: 'api/leagues/1/draft_picks/1')
        .not_to route_to('api/leagues/draft_picks#show', id: '1', league_id: '1')
    end


    it 'does not route to #create' do
      expect(post: 'api/leagues/1/draft_picks').not_to route_to('api/leagues/draft_picks#create', league_id: '1')
    end

    it 'routes to #update via PUT' do
      expect(put: 'api/leagues/1/draft_picks/1').to route_to('api/leagues/draft_picks#update', id: '1', league_id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: 'api/leagues/1/draft_picks/1')
        .to route_to('api/leagues/draft_picks#update', id: '1', league_id: '1')
    end

    it 'does not route to #destroy' do
      expect(delete: 'api/leagues/1/draft_picks/1')
        .not_to route_to('api/leaguesdraft_picks#destroy', id: '1', league_id: '1')
    end
  end
end
