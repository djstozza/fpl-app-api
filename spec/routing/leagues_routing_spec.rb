require 'rails_helper'

RSpec.describe Api::LeaguesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: 'api/leagues').to route_to('api/leagues#index')
    end

    it 'routes to #show' do
      expect(get: 'api/leagues/1').to route_to('api/leagues#show', id: '1')
    end


    it 'routes to #create' do
      expect(post: 'api/leagues').to route_to('api/leagues#create')
    end

    it 'routes to #update via PUT' do
      expect(put: 'api/leagues/1').to route_to('api/leagues#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: 'api/leagues/1').to route_to('api/leagues#update', id: '1')
    end

    it 'does not route to #edit' do
      expect(patch: 'api/leagues/1/edit').not_to route_to('api/leagues#edit', id: '1')
    end

    it 'does not route to #destroy' do
      expect(patch: 'api/leagues/1/destroy').not_to route_to('api/leagues#destroy', id: '1')
    end
  end
end
