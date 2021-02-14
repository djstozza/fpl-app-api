require 'rails_helper'

RSpec.describe Api::TeamsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/teams').to route_to('api/teams#index')
    end

    it 'routes to #show' do
      expect(get: '/api/teams/1').to route_to('api/teams#show', id: '1')
    end
  end
end
