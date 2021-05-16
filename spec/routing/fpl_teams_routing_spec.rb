require 'rails_helper'

RSpec.describe Api::FplTeamsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: 'api/fpl_teams').to route_to('api/fpl_teams#index')
    end

    it 'routes to #show' do
      expect(get: 'api/fpl_teams/1').to route_to('api/fpl_teams#show', id: '1')
    end

    it 'routes to #create' do
      expect(post: 'api/fpl_teams').to route_to('api/fpl_teams#create')
    end

    it 'routes to #update via PUT' do
      expect(put: 'api/fpl_teams/1').to route_to('api/fpl_teams#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: 'api/fpl_teams/1').to route_to('api/fpl_teams#update', id: '1')
    end

    it 'does not route to #edit' do
      expect(patch: 'api/fpl_teams/1/edit').not_to route_to('api/fpl_teams#edit', id: '1')
    end

    it 'does not route to #destroy' do
      expect(patch: 'api/fpl_teams/1/destroy').not_to route_to('api/fpl_teams#destroy', id: '1')
    end
  end
end
