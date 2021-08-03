require 'rails_helper'

RSpec.describe Api::ListPositionsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: 'api/list_positions').not_to route_to('api/list_positions#index')
    end

    it 'routes to #show' do
      expect(get: 'api/list_positions/1').to route_to('api/list_positions#show', id: '1')
    end

    it 'routes to #create' do
      expect(post: 'api/list_positions').not_to route_to('api/list_positions#create')
    end

    it 'routes to #update via PUT' do
      expect(put: 'api/list_positions/1').not_to route_to('api/list_positions#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: 'api/list_positions/1').not_to route_to('api/list_positions#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: 'api/list_positions/1').not_to route_to('api/list_positions#destroy', id: '1')
    end
  end
end
